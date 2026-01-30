defmodule ElixirRadio.Repo.Migrations.AddGenreToAlbums do
  use Ecto.Migration

  def change do
    alter table(:albums) do
      add(:genre_id, references(:genres, on_delete: :nilify_all))
    end

    create(index(:albums, [:genre_id]))
  end
end
