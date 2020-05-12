<script>
  import { onMount } from "svelte";
  export let local_media = null;

  let videoInputs = [];
  let audioInputs = [];

  onMount(async () => {
    // Get the initial set of cameras connected
    videoInputs = await getConnectedDevices("videoinput");
    audioInputs = await getConnectedDevices("audioinput");
    console.info("videoInputs:", videoInputs);
    console.info("audioInputs:", audioInputs);

    // Listen for changes to media devices and update the list accordingly
    navigator.mediaDevices.addEventListener("devicechange", async event => {
      videoInputs = await getConnectedDevices("videoinput");
      audioInputs = await getConnectedDevices("audioinput");
      console.info("videoInputs:", videoInputs);
      console.info("audioInputs:", audioInputs);
    });

    connect();
  });

  // Fetch an array of devices of a certain type
  async function getConnectedDevices(type) {
    const devices = await navigator.mediaDevices.enumerateDevices();
    return devices.filter(device => device.kind === type);
  }

  // get user permissions and set on media var
  async function connect() {
    let constraints = null;
    if (videoInputs.length > 0 && audioInputs.length > 0) {
      constraints = {
        audio: {
          echoCancellation: true
        },
        video: true
      };
    }
    if (videoInputs.length < 1 && audioInputs.length > 0) {
      constraints = {
        audio: {
          echoCancellation: true
        }
      };
    }
    if (audioInputs.length < 0) {
      alert("YOU NEED AT LEAST AUDIO YOUR FOOL!");
      console.warn("YOU NEED AT LEAST AUDIO YOUR FOOL!");
    }

    try {
      local_media = await navigator.mediaDevices.getUserMedia(constraints);
    } catch (error) {
      console.error("Error opening video camera.", error);
    }
  }
</script>

<section>
  <h1>We need access to your media devices to coninue</h1>
  <label>Video inputs</label>
  {#each videoInputs as video}
    <p>{video.label + '[' + video.deviceId + ']'}</p>
  {/each}

  <label>Audio inputs:</label>
  {#each audioInputs as audio}
    <p>{audio.label + '[' + audio.deviceId + ']'}</p>
  {/each}

  <button on:click={connect}>Retry connection</button>
</section>
