defmodule ElixirRadio.Catalog.Genre do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :image_url, :inserted_at, :updated_at]}
  schema "genres" do
    field(:name, :string)
    field(:description, :string)
    field(:image_url, :string)

    has_many(:albums, ElixirRadio.Catalog.Album)

    timestamps()
  end

  @doc false
  def changeset(genre, attrs) do
    genre
    |> cast(attrs, [:name, :description, :image_url])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
