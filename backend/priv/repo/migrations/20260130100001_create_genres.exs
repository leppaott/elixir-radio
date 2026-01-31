defmodule ElixirRadio.Repo.Migrations.CreateGenres do
  use Ecto.Migration

  def change do
    create table(:genres) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:image_url, :string)

      timestamps()
    end

    create(unique_index(:genres, [:name]))
  end
end
