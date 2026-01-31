defmodule ElixirRadio.Repo.Migrations.CreateSegments do
  use Ecto.Migration

  def change do
    create table(:segments) do
      add(:track_id, references(:tracks, on_delete: :delete_all), null: false)
      add(:playlist_data, :binary, null: false)
      add(:segment_files, :map, null: false, default: %{})
      add(:processing_status, :string, default: "pending", null: false)
      add(:processing_error, :text)

      timestamps()
    end

    create(unique_index(:segments, [:track_id]))
    create(index(:segments, [:processing_status]))
  end
end
