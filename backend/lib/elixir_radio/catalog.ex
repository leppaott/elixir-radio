defmodule ElixirRadio.Catalog do
  @moduledoc """
  The Catalog context - handles artists, albums, tracks, genres, uploads, and segments.
  """

  import Ecto.Query, warn: false
  alias ElixirRadio.Repo
  alias ElixirRadio.Catalog.{Artist, Album, Track, Genre, Upload, Segment, SegmentFile}

  # Genres

  def list_genres(opts \\ []) do
    query = from(g in Genre)

    paginate(query, opts)
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
    query =
      Album
      |> where([a], a.genre_id == ^genre_id)
      |> preload([:artist, :tracks, :genre])

    paginate(query, opts)
  end

  def list_albums(opts \\ []) do
    query =
      Album
      |> preload([:artist, :tracks, :genre])

    paginate(query, opts)
  end

  def list_albums_by_artist(artist_id, opts \\ []) do
    query =
      Album
      |> where([a], a.artist_id == ^artist_id)
      |> preload([:artist, :tracks, :genre])

    paginate(query, opts)
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

  @doc """
  Creates an album with nested tracks in a single transaction.
  Returns {:ok, album} with tracks preloaded, or {:error, changeset}.

  ## Example
      create_album_with_tracks(
        %{title: "Album", artist_id: 1, genre_id: 1},
        [%{title: "Track 1", track_number: 1}, %{title: "Track 2", track_number: 2}]
      )
  """
  def create_album_with_tracks(album_attrs, tracks_attrs) when is_list(tracks_attrs) do
    Repo.transaction(fn ->
      with {:ok, album} <- create_album(album_attrs),
           {:ok, tracks} <- create_tracks_for_album(album.id, tracks_attrs) do
        %{album | tracks: tracks}
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp create_tracks_for_album(album_id, tracks_attrs) do
    tracks =
      Enum.map(tracks_attrs, fn track_attrs ->
        track_attrs
        |> Map.put("album_id", album_id)
        |> then(&Track.changeset(%Track{}, &1))
      end)

    case Enum.find(tracks, fn cs -> not cs.valid? end) do
      nil ->
        tracks = Enum.map(tracks, &Repo.insert!/1)
        {:ok, tracks}

      invalid_changeset ->
        {:error, invalid_changeset}
    end
  end

  @doc """
  Gets album status with all tracks and their upload/processing status.
  """
  def get_album_status(album_id) do
    case Repo.get(Album, album_id) do
      nil ->
        {:error, :not_found}

      album ->
        album = Repo.preload(album, [:artist, :genre, tracks: [:upload, :segment]])

        status_data = %{
          album_id: album.id,
          title: album.title,
          artist: album.artist.name,
          genre: album.genre.name,
          tracks:
            Enum.map(album.tracks, fn track ->
              %{
                id: track.id,
                title: track.title,
                track_number: track.track_number,
                upload_status: track.upload_status,
                has_upload: track.upload != nil,
                processing_status:
                  if(track.segment, do: track.segment.processing_status, else: nil),
                upload_url: "/admin/tracks/#{track.id}/upload"
              }
            end)
            |> Enum.sort_by(& &1.track_number),
          complete: Enum.all?(album.tracks, &(&1.upload_status == "ready")),
          ready_count: Enum.count(album.tracks, &(&1.upload_status == "ready")),
          processing_count: Enum.count(album.tracks, &(&1.upload_status == "processing")),
          pending_count: Enum.count(album.tracks, &(&1.upload_status == "pending")),
          total_count: length(album.tracks)
        }

        {:ok, status_data}
    end
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
    query =
      from(t in Track,
        join: a in Album,
        on: t.album_id == a.id,
        where: a.genre_id == ^genre_id and t.upload_status == "ready",
        preload: [album: [:artist, :genre], segment: []]
      )

    paginate(query, opts)
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

  def get_segment_file(segment_id, index) do
    Repo.get_by(SegmentFile, segment_id: segment_id, index: index)
  end

  # Pagination helper - supports cursor-based pagination with after_id
  defp paginate(query, opts) do
    per_page = Keyword.get(opts, :per_page, 20)
    after_id = Keyword.get(opts, :after_id)
    sort_by = Keyword.get(opts, :sort_by, :id)
    sort_order = Keyword.get(opts, :sort_order, :asc)

    # Apply sorting - always include id as secondary sort for consistency
    query =
      if sort_by == :id do
        order_by(query, [{^sort_order, :id}])
      else
        order_by(query, [{^sort_order, ^sort_by}, {^sort_order, :id}])
      end

    # Apply cursor filter if after_id is provided (always filter by ID)
    query =
      if after_id do
        where(query, [r], r.id > ^after_id)
      else
        query
      end

    # Fetch items + 1 to check if there are more
    items = query |> limit(^(per_page + 1)) |> Repo.all()

    has_more = length(items) > per_page
    items = Enum.take(items, per_page)

    next_cursor = if has_more and length(items) > 0, do: List.last(items).id

    %{
      items: items,
      per_page: per_page,
      has_more: has_more,
      next_cursor: next_cursor,
      sort_by: sort_by,
      sort_order: sort_order
    }
  end
end
