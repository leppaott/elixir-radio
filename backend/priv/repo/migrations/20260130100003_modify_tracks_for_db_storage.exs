defmodule ElixirRadio.Repo.Migrations.ModifyTracksForDbStorage do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      remove(:stream_id)
      remove(:file_path)
      add(:upload_status, :integer, default: 0, null: false)
    end

    create(index(:tracks, [:upload_status]))
  end
end
