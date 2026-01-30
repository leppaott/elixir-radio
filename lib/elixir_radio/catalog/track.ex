defmodule ElixirRadio.Catalog.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @upload_statuses ~w(pending processing ready failed)

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :album_id,
             :album,
             :track_number,
             :duration_seconds,
             :sample_duration,
             :upload_status,
             :inserted_at,
             :updated_at
           ]}
  schema "tracks" do
    field(:title, :string)
    field(:track_number, :integer)
    field(:duration_seconds, :integer)
    field(:sample_duration, :integer, default: 120)
    field(:upload_status, :string, default: "pending")

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
    |> validate_inclusion(:upload_status, @upload_statuses)
    |> validate_number(:sample_duration, greater_than: 0, less_than_or_equal_to: 240)
    |> foreign_key_constraint(:album_id)
  end
end
