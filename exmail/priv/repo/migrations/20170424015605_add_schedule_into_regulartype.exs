defmodule Exmail.Repo.Migrations.AddScheduleIntoRegulartype do
  use Ecto.Migration

  def change do
    alter table(:regulartypes) do
      add :schedule, :utc_datetime
    end
  end
end
