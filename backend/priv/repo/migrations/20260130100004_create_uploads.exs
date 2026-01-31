defmodule ElixirRadio.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add(:track_id, references(:tracks, on_delete: :delete_all), null: false)
      add(:original_filename, :string, null: false)
      add(:file_data, :binary, null: false)
      add(:mime_type, :string)
      add(:file_size, :bigint)

      timestamps()
    end

    create(unique_index(:uploads, [:track_id]))
  end
end
