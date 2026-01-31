defmodule ElixirRadio.Repo.Migrations.CreateSegments do
  use Ecto.Migration

  def change do
    create table(:segments) do
      add(:track_id, references(:tracks, on_delete: :delete_all), null: false)
      add(:playlist_data, :binary, null: false)
      add(:processing_status, :integer, default: 0, null: false)
      add(:processing_error, :text)

      timestamps()
    end

    create(unique_index(:segments, [:track_id]))
    create(index(:segments, [:processing_status]))

    create table(:segment_files) do
      add(:segment_id, references(:segments, on_delete: :delete_all), null: false)
      add(:index, :integer, null: false)
      add(:data, :binary, null: false)

      timestamps()
    end

    create(index(:segment_files, [:segment_id]))
    create(unique_index(:segment_files, [:segment_id, :index]))
  end
end
