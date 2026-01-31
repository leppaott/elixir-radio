defmodule ElixirRadio.AdminArtistTest do
  use ElixirRadio.ConnCase, async: false

  import ElixirRadio.Factory
  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog

  describe "POST /admin/artists - create artist" do
    test "creates artist and returns artist_id" do
      conn =
        build_conn()
        |> post("/admin/artists", %{
          "name" => "New Artist",
          "bio" => "A new artist bio",
          "image_url" => "http://example.com/image.jpg"
        })

      response = json_response(conn, 201)
      assert response["artist_id"]
      artist = Catalog.get_artist!(response["artist_id"])
      assert artist.name == "New Artist"
      assert artist.bio == "A new artist bio"
      assert artist.image_url == "http://example.com/image.jpg"
    end

    test "returns errors for missing name" do
      conn =
        build_conn()
        |> post("/admin/artists", %{"bio" => "No name"})

      response = json_response(conn, 400)
      assert response["errors"]["name"]
    end
  end
end
