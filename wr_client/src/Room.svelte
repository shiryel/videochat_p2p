<script>
  // Sequence:
  // 1 -> new peer -> send offer -|
  //         |- (wait answer)     |
  //                              v
  // 2 -> new peer -----------> wait offer -> send answer
  //
  // RULES FOR THIS TO WORK:
  //
  // Media:
  // - LOCAL -> send media
  // - REMOTE -> receive media
  //
  // Offer:
  // - LOCAL -> send each 2 seconds (with the local_peer_connection)
  // - REMOTE -> only answer the 'offered' (creating a new remote_peer_connection)
  //
  // DONT MESS WITH THIS RULES!
  import { onMount } from "svelte";

  export let local_media = null;
  export let channel = null;
  export let room_id = null;

  let peers = [];

  // to start a new connection (both local and remote)
  function new_peer(id, channel, local_media) {
    const configuration = {
      iceServers: [
        { urls: "stun:stun.l.google.com:19302" }
        //{
        //  urls: ["stun:stun.stunprotocol.org"]
        //},
        //{
        //  urls: ["turn:www.videowe.app:3478"],
        //  username: "videome",
        //  credential: "videome"
        //}
      ]
    };
    const peer_connection = new RTCPeerConnection(configuration);

    peer_connection.onicecandidate = event => {
      if (event.candidate)
        sendSignaling(channel, "ice_candidate", event.candidate, id);
    };

    // IMPORTANT TO MAKE THE ICE SCREAMS WORKS (serious dude I lost literaly 6 hours because of this 3 lines...)
    const remote_media = new MediaStream();
    local_media.getTracks().forEach(track => peer_connection.addTrack(track));
    peer_connection.ontrack = e => remote_media.addTrack(e.track);

    peer_connection.addEventListener("connectionstatechange", event => {
      if (peerConnection.connectionState === "connected") {
        console.log("peer connected");
      }
    });

    return { connection: peer_connection, media: remote_media, id: id };
  }

  // verify if the browser supports the webRTC
  // if not will make a alert and return false
  function verifyWebRtcSupport() {
    if (!("RTCPeerConnection" in window) || !("mediaDevices" in navigator)) {
      alert("Your browser doesn't support WebRTC");
      return false;
    }
    return true;
  }

  // (on 1) make a offer to all connections in the channel
  async function make_offer({ connection, id }, channel) {
    let offer = await connection.createOffer();
    sendSignaling(channel, "offer", offer, id);

    // start sending ice candidates
    await connection.setLocalDescription(offer);
  }

  // (on 2) answer a offer and start receving icecandidates
  async function make_answer({ connection, id }, channel, offer) {
    connection.setRemoteDescription(new RTCSessionDescription(offer));
    let answer = await connection.createAnswer();
    sendSignaling(channel, "answer", answer, id);

    // start sending ice candidates
    await connection.setLocalDescription(answer);
  }

  // (on 1) receve the answer and start receving icecandidates
  async function registry_answer({ connection, id }, answer) {
    await connection.setRemoteDescription(new RTCSessionDescription(answer));
  }

  // (on 1 and 2) receive the ice candidate
  async function addIceCandidate({ connection }, ice_candidate) {
    try {
      await connection.addIceCandidate(ice_candidate);
    } catch (e) {
      console.error("Error adding received ice candidate", e);
    }
  }

  // send a message through the websocket channel (elixir)
  function sendSignaling(channel, type, content, id) {
    console.debug("sendSignaling: type:", type, "content:", content);
    channel.push("peer-message", {
      type: type,
      content: content,
      id: id
    });
  }

  function getPeerById(peers, id) {
    return peers.find(x => x.id == id);
  }

  function random() {
    return Math.random()
      .toString()
      .slice(2);
  }

  async function handleChannel(channel) {
    let peer = null;
    channel.on("peer-message", async ({ type, id, content } = payload) => {
      switch (type) {
        // on 1 (send offer)
        case "open_connection":
          peer = new_peer(random(), channel, local_media);
          peers = [...peers, peer];
          await make_offer(peer, channel);
          break;

        // on 2 (receive offer)
        case "offer":
          console.debug("offered: ", content, "id: ", id);
          peer = new_peer(id, channel, local_media);
          peers = [...peers, peer];
          await make_answer(peer, channel, content);
          break;

        // on 1 (receive answer)
        case "answer":
          console.debug("answered: ", content);
          peer = getPeerById(peers, id);
          await registry_answer(peer, content);
          break;

        // on 1 and 2
        case "ice_candidate":
          console.debug("ice_candidate: ", content);
          peer = getPeerById(peers, id);
          if(peer)
            await addIceCandidate(peer, content);
          break;

        // on 1 and 2
        case "disconnect":
          console.debug("disconnect: ", content);
          break;

        default:
          console.warn("unhandled message:", content, "type:", type);
      }
    });
  }

  onMount(async () => {
    verifyWebRtcSupport();
    const local_video = document.querySelector(`#local_video`);
    local_video.srcObject = local_media;

    await handleChannel(channel);

    sendSignaling(channel, "open_connection", "", 0);

    const interval = setInterval(() => {
      // FIXME: do not update when alread setted
      for (let peer of peers) {
        let remote_video = document.querySelector(`#remote_video_${peer.id}`);
        remote_video.srcObject = peer.media;
      }
    }, 7000);

    return () => {
      clearInterval(interval);
    };
  });
</script>

<section>
  <h1>{room_id}</h1>
  <video id="local_video" autoplay playsinline controls="false">
    Your browser does not support the video tag!
  </video>
  {#each peers as { id }}
    <video id="remote_video_{id}" autoplay playsinline controls="false">
      Your browser does not support the video tag!
    </video>
  {/each}
</section>
