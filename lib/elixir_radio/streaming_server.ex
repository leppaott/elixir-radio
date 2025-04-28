defmodule ElixirRadio.StreamingServer do
  use Plug.Router

  plug(Plug.Logger)

  # Serve static files from /data directory with custom headers for m3u8 files (playlists)
  plug(Plug.Static,
    at: "/streams",
    from: "/data",
    headers: {ElixirRadio.StaticHeaders, :headers, []}
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "Elixir Radio Streaming Server")
  end

  get "/health" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "ok"}))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
