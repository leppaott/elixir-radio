defmodule ElixirRadio.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add(:title, :string, null: false)
      add(:album_id, references(:albums, on_delete: :delete_all), null: false)
      add(:track_number, :integer, null: false)
      add(:duration_seconds, :integer)
      add(:sample_duration, :integer, default: 60)
      add(:file_path, :string)
      add(:stream_id, :string)

      timestamps()
    end

    create(index(:tracks, [:album_id]))
    create(unique_index(:tracks, [:stream_id]))
  end
end
