defmodule ElixirRadio.Catalog.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :bio, :image_url, :inserted_at, :updated_at]}
  schema "artists" do
    field(:name, :string)
    field(:bio, :string)
    field(:image_url, :string)

    has_many(:albums, ElixirRadio.Catalog.Album)

    timestamps()
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :bio, :image_url])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
