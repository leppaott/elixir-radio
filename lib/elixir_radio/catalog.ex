defmodule ElixirRadio.Catalog do
  @moduledoc """
  The Catalog context - handles artists, albums, tracks, genres, uploads, and segments.
  """

  import Ecto.Query, warn: false
  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog.{Artist, Album, Track, Genre, Upload, Segment}

  # Genres

  def list_genres do
    Repo.all(Genre)
  end

  def get_genre!(id), do: Repo.get!(Genre, id)

  def get_genre(id) do
    case Repo.get(Genre, id) do
      nil -> {:error, :not_found}
      genre -> {:ok, genre}
    end
  end

  def get_genre_by_name(name) do
    query = from(g in Genre, where: ilike(g.name, ^name))

    case Repo.one(query) do
      nil -> {:error, :not_found}
      genre -> {:ok, genre}
    end
  end

  def create_genre(attrs \\ %{}) do
    %Genre{}
    |> Genre.changeset(attrs)
    |> Repo.insert()
  end

  # Artists

  def get_artist!(id), do: Repo.get!(Artist, id)

  def get_artist(id) do
    case Repo.get(Artist, id) do
      nil -> {:error, :not_found}
      artist -> {:ok, artist}
    end
  end

  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  # Albums with pagination

  def get_album(id) do
    case Repo.get(Album, id) do
      nil -> {:error, :not_found}
      album -> {:ok, Repo.preload(album, [:artist, :genre, tracks: [:segment]])}
    end
  end

  def list_albums_by_genre(genre_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    query =
      Album
      |> where([a], a.genre_id == ^genre_id)
      |> preload([:artist, :tracks, :genre])
      |> order_by([a], desc: a.inserted_at)

    paginate(query, page, per_page)
  end

  def list_albums_by_artist(artist_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    query =
      Album
      |> where([a], a.artist_id == ^artist_id)
      |> preload([:artist, :tracks, :genre])
      |> order_by([a], desc: a.release_year)

    paginate(query, page, per_page)
  end

  def get_album!(id) do
    Album
    |> Repo.get!(id)
    |> Repo.preload([:artist, :genre, tracks: [:segment]])
  end

  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  # Tracks

  def get_track!(id) do
    Track
    |> Repo.get!(id)
    |> Repo.preload(album: [:artist, :genre], segment: [], upload: [])
  end

  def get_track(id) do
    case Repo.get(Track, id) do
      nil -> {:error, :not_found}
      track -> {:ok, Repo.preload(track, album: [:artist, :genre], segment: [], upload: [])}
    end
  end

  def update_track_status(id, status)
      when status in ["pending", "processing", "ready", "failed"] do
    case get_track!(id) do
      nil ->
        {:error, :not_found}

      track ->
        track
        |> Track.changeset(%{upload_status: status})
        |> Repo.update()
    end
  end

  def list_tracks_by_genre(genre_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 50)

    query =
      from(t in Track,
        join: a in Album,
        on: t.album_id == a.id,
        where: a.genre_id == ^genre_id and t.upload_status == "ready",
        preload: [album: [:artist, :genre], segment: []],
        order_by: [desc: t.inserted_at]
      )

    paginate(query, page, per_page)
  end

  def create_track(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  # Uploads

  def create_upload(attrs \\ %{}) do
    %Upload{}
    |> Upload.changeset(attrs)
    |> Repo.insert()
  end

  def create_or_replace_upload(attrs \\ %{}) do
    %Upload{}
    |> Upload.changeset(attrs)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :track_id)
  end

  def get_upload_by_track(track_id) do
    Repo.get_by(Upload, track_id: track_id)
  end

  # Segments

  def get_segment_by_track(track_id) do
    Repo.get_by(Segment, track_id: track_id)
  end

  # Pagination helper
  defp paginate(query, page, per_page) do
    offset = (page - 1) * per_page

    items = query |> limit(^per_page) |> offset(^offset) |> Repo.all()
    total_count = query |> exclude(:preload) |> exclude(:order_by) |> Repo.aggregate(:count)

    %{
      items: items,
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: ceil(total_count / per_page)
    }
  end
end
