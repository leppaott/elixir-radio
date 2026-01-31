defmodule ElixirRadio.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add(:name, :string, null: false)
      add(:bio, :text)
      add(:image_url, :string)

      timestamps()
    end

    create(unique_index(:artists, [:name]))
  end
end
