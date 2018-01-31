defmodule Exmail.Repo.Migrations.AddTimestampOnActivity do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :timestamp, :utc_datetime
    end
    create index(:activities, [:timestamp])
  end
end
