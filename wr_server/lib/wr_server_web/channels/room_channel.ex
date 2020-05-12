defmodule WrServerWeb.RoomChannel do
  @moduledoc """
  The room where a meeting occurs
  """
  use WrServerWeb, :channel

  def join("room:" <> _room, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("peer-message", payload, socket) do
    broadcast_from(socket, "peer-message", payload)
    {:noreply, socket}
  end
end
