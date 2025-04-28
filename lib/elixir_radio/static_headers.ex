defmodule ElixirRadio.StaticHeaders do
  def headers(conn) do
    filename = List.last(conn.path_info)

    cors_headers() ++ content_type_headers(filename)
  end

  defp cors_headers do
    [
      {"access-control-allow-origin", "*"},
      {"access-control-allow-methods", "GET, OPTIONS"},
      {"access-control-allow-headers", "Origin, X-Requested-With, Content-Type, Accept"}
    ]
  end

  defp content_type_headers(filename) do
    case Path.extname(filename) do
      ".m3u8" -> [{"content-type", "application/vnd.apple.mpegurl"}]
      ".ts" -> [{"content-type", "video/mp2t"}]
      _ -> []
    end
  end
end
