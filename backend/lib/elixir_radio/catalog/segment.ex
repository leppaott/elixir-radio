defmodule ElixirRadio.Catalog.Segment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "segments" do
    field(:playlist_data, :binary)

    field(:processing_status, Ecto.Enum,
      values: [pending: 0, processing: 1, completed: 2, failed: 3],
      default: :pending,
      embed_as: :dumped
    )

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
    |> foreign_key_constraint(:track_id)
    |> unique_constraint(:track_id)
  end
end
