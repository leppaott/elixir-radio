defmodule ElixirRadio.Catalog.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field(:original_filename, :string)
    field(:file_data, :binary)
    field(:mime_type, :string)
    field(:file_size, :integer)

    belongs_to(:track, ElixirRadio.Catalog.Track)

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:track_id, :original_filename, :file_data, :mime_type, :file_size])
    |> validate_required([:track_id, :original_filename, :file_data])
    |> foreign_key_constraint(:track_id)
    |> unique_constraint(:track_id)
    # 50 MB
    |> validate_number(:file_size, less_than_or_equal_to: 52_428_800)
  end
end
