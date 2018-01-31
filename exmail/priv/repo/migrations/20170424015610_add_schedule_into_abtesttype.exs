defmodule Exmail.Repo.Migrations.AddScheduleIntoAbtesttype do
  use Ecto.Migration

  def change do
    alter table(:abtesttypes) do
      add :schedule, :utc_datetime
    end
  end
end
