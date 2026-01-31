defmodule ElixirRadio.Repo.Migrations.AddAltTrackNumberToTracks do
  use Ecto.Migration

  def change do
    alter table(:tracks) do
      add(:alt_track_number, :string, size: 10)
    end
  end
end
