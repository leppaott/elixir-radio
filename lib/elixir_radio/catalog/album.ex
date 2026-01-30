defmodule ElixirRadio.Catalog.Album do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :artist_id,
             :artist,
             :genre_id,
             :genre,
             :release_year,
             :cover_image_url,
             :description,
             :inserted_at,
             :updated_at
           ]}
  schema "albums" do
    field(:title, :string)
    field(:release_year, :integer)
    field(:cover_image_url, :string)
    field(:description, :string)

    belongs_to(:artist, ElixirRadio.Catalog.Artist)
    belongs_to(:genre, ElixirRadio.Catalog.Genre)
    has_many(:tracks, ElixirRadio.Catalog.Track)

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:title, :artist_id, :genre_id, :release_year, :cover_image_url, :description])
    |> validate_required([:title, :artist_id])
    |> foreign_key_constraint(:artist_id)
    |> foreign_key_constraint(:genre_id)
  end
end
