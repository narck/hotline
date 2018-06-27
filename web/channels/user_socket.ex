defmodule Chat.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", Chat.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  #def connect(_params, socket) do
  #  {:ok, socket}
  #end

  def connect(%{"user" => user} = params, socket) do
    {:ok, assign(socket, :user, user)}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Chat.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end

defmodule Chat.RoomChannel do
  use Chat.Web, :channel
  alias Chat.Presence

  def join("room:lobby", _, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user, %{
      online_at: :os.system_time(:milli_seconds)
    })

    push socket, "presence_state", Presence.list(socket)

    user = socket.assigns.user
    if user == "kalex" do
      push socket, "message:history", %{history: message_history}
    end
    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    broadcast! socket, "message:new", %{
      user: socket.assigns.user,
      body: message,
      timestamp: :os.system_time(:milli_seconds)
    }
    {:noreply, socket}
  end


  defp message_history() do
    [
      %{
        user: "steve",
        body: "adam and eve",
        timestamp: :os.system_time(:milli_seconds)
      },
      %{
        user: "adam",
        body: "and steve",
        timestamp: :os.system_time(:milli_seconds)
      },
      %{
        user: "steve",
        body: "hi!",
        timestamp: :os.system_time(:milli_seconds)
      },
      %{
        user: "adam",
        body: "hello",
        timestamp: :os.system_time(:milli_seconds)
      }
    ]
  end
end
