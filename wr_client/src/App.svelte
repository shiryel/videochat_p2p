<script>
  import Phoenix from "phoenix";
  import Home from "./Home.svelte";
  import Media from "./Media.svelte";
  import Room from "./Room.svelte";

  // SOCKET
  let socket = new Phoenix.Socket("ws://localhost:4000/socket", { params: {} });
  socket.connect();
  socket.onError(() => console.log("there was an error with the connection!"));
  socket.onClose(() => console.log("the connection dropped"));

  // to show the id on Room.svelte
  let room_id = null;
  // when not null, will go to the Media.svelte
  let channel = null;
  // when not null, will go to the Room.svelte
  let local_media = null;
</script>

<style>
  main {
    text-align: center;
    padding: 1em;
    max-width: 240px;
    margin: 0 auto;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 4em;
    font-weight: 100;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>

<main>
  {#if (!channel)}
    <Home bind:socket bind:room_id bind:channel />
  {/if}
  {#if (channel && !local_media)}
    <Media bind:local_media />
  {/if}
  {#if (channel && local_media)}
    <Room bind:room_id bind:channel bind:local_media />
  {/if}
</main>
