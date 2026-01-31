defmodule ElixirRadio.Catalog.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :album_id,
             :album,
             :track_number,
             :alt_track_number,
             :duration_seconds,
             :sample_duration,
             :upload_status,
             :inserted_at,
             :updated_at
           ]}
  schema "tracks" do
    field(:title, :string)
    field(:track_number, :integer)
    field(:alt_track_number, :string)
    field(:duration_seconds, :integer)
    field(:sample_duration, :integer, default: 120)

    field(:upload_status, Ecto.Enum,
      values: [pending: 0, processing: 1, ready: 2, failed: 3],
      default: :pending,
      embed_as: :dumped
    )

    belongs_to(:album, ElixirRadio.Catalog.Album)
    has_one(:upload, ElixirRadio.Catalog.Upload)
    has_one(:segment, ElixirRadio.Catalog.Segment)

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [
      :title,
      :album_id,
      :track_number,
      :duration_seconds,
      :sample_duration,
      :upload_status
    ])
    |> validate_required([:title, :album_id, :track_number])
    |> validate_number(:sample_duration, greater_than: 0, less_than_or_equal_to: 240)
    |> foreign_key_constraint(:album_id)
  end
end
