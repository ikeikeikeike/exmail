defmodule Exmail.Repo.Migrations.AddScheduleIntoTexttype do
  use Ecto.Migration

  def change do
    alter table(:texttypes) do
      add :schedule, :utc_datetime
    end
  end
end
