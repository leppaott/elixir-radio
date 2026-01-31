defmodule ElixirRadio.Catalog.Segment do
  use Ecto.Schema
  import Ecto.Changeset

  @processing_statuses ~w(pending processing completed failed)

  schema "segments" do
    field(:playlist_data, :binary)
    field(:processing_status, :string, default: "pending")
    field(:processing_error, :string)

    belongs_to(:track, ElixirRadio.Catalog.Track)
    has_many(:files, ElixirRadio.Catalog.SegmentFile)

    timestamps()
  end

  @doc false
  def changeset(segment, attrs) do
    segment
    |> cast(attrs, [
      :track_id,
      :playlist_data,
      :processing_status,
      :processing_error
    ])
    |> validate_required([:track_id])
    |> validate_inclusion(:processing_status, @processing_statuses)
    |> foreign_key_constraint(:track_id)
    |> unique_constraint(:track_id)
  end
end
