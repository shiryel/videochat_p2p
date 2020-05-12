<script>
  export let socket = null;

  // to show the id on Room.svelte
  export let room_id = null;
  // when not null, will go to the Media.svelte
  export let channel = null;

  function connectRoom() {
    if (room_id) {
      join();
    }
  }

  function newRoom() {
    room_id = Math.random().toString().slice(2)
    join();
  }

  function join() {
    let ch = socket.channel(`room:${room_id}`, {});

    ch
      .join()
      .receive("ok", () => {
        console.log("Joined Room");
        channel = ch;
      })
      .receive("error", ({ reason }) => {
        console.log("Failed to join Room", reason);
      })
      .receive("timeout", () => {
        console.log("Networking issue. Still waiting...");
      });
  }
</script>

<section>
  <h1>WebRTC</h1>
  <input bind:value={room_id} placeholder="Room ID"/>
  <button on:click={connectRoom}>Connect to room</button>
  <button on:click={newRoom}>New Room</button>
</section>
