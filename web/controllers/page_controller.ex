defmodule Chat.PageController do
  use Chat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def sms_relay(conn, %{"say" => say} = params) do
    Chat.Endpoint.broadcast "room:lobby", "pp:talk", %{}
    HTTPoison.post!("http://localhost:4001/guzell", "{\"say\": \"#{say}\"}", [{"Content-Type", "application/json"}])
    Chat.Endpoint.broadcast "room:lobby", "pp:end", %{}

    text conn, "ok"
  end
end
