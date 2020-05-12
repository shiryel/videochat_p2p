defmodule WrServerWeb.RoomChannelTest do
  use WrServerWeb.ChannelCase

  setup do
    {:ok, _, _socket} =
      socket(WrServerWeb.UserSocket, nil, %{})
      |> subscribe_and_join(WrServerWeb.RoomChannel, "room:123", %{})

    %{socket: socket}
  end

  test "can send a peer-message", %{socket: socket} do
    push(socket, "peer-message", %{"test" => "test"})
    assert_broadcast("peer-message", %{"test" => "test"})
  end
end
