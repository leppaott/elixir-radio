defmodule ElixirRadio.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add(:title, :string, null: false)
      add(:artist_id, references(:artists, on_delete: :delete_all), null: false)
      add(:release_year, :integer)
      add(:cover_image_url, :string)
      add(:description, :text)

      timestamps()
    end

    create(index(:albums, [:artist_id]))
  end
end
