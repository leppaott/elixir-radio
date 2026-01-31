defmodule ElixirRadio.CatalogTest do
  use ElixirRadio.DataCase
  import ElixirRadio.Factory

  alias ElixirRadio.Catalog

  describe "genres" do
    test "list_genres/0 returns all genres" do
      genre1 = insert!(:genre, name: "Electronic")
      genre2 = insert!(:genre, name: "Jazz")

      result = Catalog.list_genres()
      genres = result.items

      assert length(genres) == 2
      assert Enum.any?(genres, &(&1.id == genre1.id))
      assert Enum.any?(genres, &(&1.id == genre2.id))
    end

    test "get_genre/1 returns genre by id" do
      genre = insert!(:genre, name: "Electronic")

      assert {:ok, found_genre} = Catalog.get_genre(genre.id)
      assert found_genre.id == genre.id
      assert found_genre.name == "Electronic"
    end

    test "get_genre/1 returns error when genre doesn't exist" do
      assert {:error, :not_found} = Catalog.get_genre(999)
    end

    test "get_genre_by_name/1 returns genre by name" do
      insert!(:genre, name: "Electronic")

      assert {:ok, genre} = Catalog.get_genre_by_name("Electronic")
      assert genre.name == "Electronic"
    end

    test "get_genre_by_name/1 is case insensitive" do
      insert!(:genre, name: "Electronic")

      assert {:ok, genre} = Catalog.get_genre_by_name("electronic")
      assert genre.name == "Electronic"
    end

    test "create_genre/1 creates a genre with valid data" do
      attrs = %{
        name: "Electronic",
        description: "Electronic music",
        image_url: "https://example.com/genre.jpg"
      }

      assert {:ok, genre} = Catalog.create_genre(attrs)
      assert genre.name == "Electronic"
      assert genre.description == "Electronic music"
    end

    test "create_genre/1 returns error with invalid data" do
      assert {:error, changeset} = Catalog.create_genre(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "artists" do
    test "create_artist/1 creates an artist with valid data" do
      attrs = %{
        name: "Test Artist",
        bio: "A test bio",
        image_url: "https://example.com/artist.jpg"
      }

      assert {:ok, artist} = Catalog.create_artist(attrs)
      assert artist.name == "Test Artist"
      assert artist.bio == "A test bio"
    end

    test "get_artist/1 returns artist by id" do
      artist = insert!(:artist, name: "Test Artist")

      assert {:ok, found_artist} = Catalog.get_artist(artist.id)
      assert found_artist.id == artist.id
      assert found_artist.name == "Test Artist"
    end
  end

  describe "albums" do
    test "get_album/1 returns album with preloaded associations" do
      genre = insert!(:genre)
      artist = insert!(:artist, name: "Test Artist")

      album =
        insert!(:album, %{
          title: "Test Album",
          artist_id: artist.id,
          genre_id: genre.id
        })

      assert {:ok, found_album} = Catalog.get_album(album.id)
      assert found_album.id == album.id
      assert found_album.title == "Test Album"
      assert found_album.artist.name == "Test Artist"
    end

    test "create_album/1 creates an album with valid data" do
      genre = insert!(:genre)
      artist = insert!(:artist)

      attrs = %{
        title: "Test Album",
        artist_id: artist.id,
        genre_id: genre.id,
        release_year: 2024,
        cover_image_url: "https://example.com/album.jpg"
      }

      assert {:ok, album} = Catalog.create_album(attrs)
      assert album.title == "Test Album"
      assert album.release_year == 2024
    end

    test "list_albums/1 with genre_id returns paginated albums for genre with cursor" do
      genre = insert!(:genre)
      other_genre = insert!(:genre)
      artist = insert!(:artist)

      album1 = insert!(:album, %{artist_id: artist.id, genre_id: genre.id})
      album2 = insert!(:album, %{artist_id: artist.id, genre_id: genre.id})
      _album3 = insert!(:album, %{artist_id: artist.id, genre_id: other_genre.id})

      # First page
      result =
        Catalog.list_albums(genre_id: genre.id, per_page: 1, sort_by: :id, sort_order: :asc)

      assert result.per_page == 1
      assert length(result.items) == 1
      assert result.has_more == true
      assert result.next_cursor == album1.id

      # Second page using cursor
      result2 =
        Catalog.list_albums(
          genre_id: genre.id,
          after_id: result.next_cursor,
          per_page: 1,
          sort_by: :id,
          sort_order: :asc
        )

      assert length(result2.items) == 1
      assert result2.has_more == false
      assert hd(result2.items).id == album2.id
    end
  end

  describe "tracks" do
    test "get_track/1 returns track with album and artist" do
      genre = insert!(:genre)
      artist = insert!(:artist, name: "Test Artist")

      album =
        insert!(:album, %{
          title: "Test Album",
          artist_id: artist.id,
          genre_id: genre.id
        })

      track =
        insert!(:track, %{
          title: "Test Track",
          album_id: album.id,
          track_number: 1
        })

      assert {:ok, found_track} = Catalog.get_track(track.id)
      assert found_track.id == track.id
      assert found_track.title == "Test Track"
      assert found_track.album.title == "Test Album"
      assert found_track.album.artist.name == "Test Artist"
    end

    test "create_track/1 creates a track with valid data" do
      genre = insert!(:genre)
      artist = insert!(:artist)
      album = insert!(:album, %{artist_id: artist.id, genre_id: genre.id})

      attrs = %{
        title: "Test Track",
        album_id: album.id,
        track_number: 1,
        duration_seconds: 240,
        sample_duration: 120
      }

      assert {:ok, track} = Catalog.create_track(attrs)
      assert track.title == "Test Track"
      assert track.duration_seconds == 240
      assert track.upload_status == "pending"
    end

    test "list_tracks_by_genre/2 returns only tracks with ready status" do
      genre = insert!(:genre)
      artist = insert!(:artist)
      album = insert!(:album, %{artist_id: artist.id, genre_id: genre.id})

      _ready_track =
        insert!(:track, %{
          album_id: album.id,
          track_number: 1,
          upload_status: "ready"
        })

      _pending_track =
        insert!(:track, %{
          album_id: album.id,
          track_number: 2,
          upload_status: "pending"
        })

      result = Catalog.list_tracks_by_genre(genre.id, per_page: 10)

      assert length(result.items) == 1
      assert hd(result.items).upload_status == "ready"
    end

    test "update_track_status/2 updates track status" do
      genre = insert!(:genre)
      artist = insert!(:artist)
      album = insert!(:album, %{artist_id: artist.id, genre_id: genre.id})

      track =
        insert!(:track, %{
          album_id: album.id,
          track_number: 1,
          upload_status: "pending"
        })

      assert {:ok, updated_track} = Catalog.update_track_status(track.id, "ready")
      assert updated_track.upload_status == "ready"
    end
  end
end
