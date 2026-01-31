defmodule ElixirRadio.Catalog.SegmentFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "segment_files" do
    field(:index, :integer)
    field(:data, :binary)

    belongs_to(:segment, ElixirRadio.Catalog.Segment)

    timestamps()
  end

  @doc false
  def changeset(segment_file, attrs) do
    segment_file
    |> cast(attrs, [:segment_id, :index, :data])
    |> validate_required([:segment_id, :index, :data])
    |> foreign_key_constraint(:segment_id)
    |> unique_constraint([:segment_id, :index])
  end
end
