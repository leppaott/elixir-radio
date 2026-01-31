defmodule ElixirRadio.RootIndexTest do
  use ElixirRadio.ConnCase, async: true

  @moduletag :integration

  test "GET / serves public/index.html" do
    conn = build_conn() |> get("/")
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") |> List.first() =~ "text/html"

    # Ensure the body includes a known header from public/index.html
    assert String.contains?(conn.resp_body, "Elixir Radio")
  end
end
