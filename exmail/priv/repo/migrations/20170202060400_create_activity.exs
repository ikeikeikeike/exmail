defmodule Exmail.Repo.Migrations.CreateActivity do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :user_id, :integer
      add :report_id, :integer
      add :status, :string, comment: "open|click"  # see models/activity.ex

      timestamps()
    end
    create index(:activities, [:user_id])
    create index(:activities, [:report_id])
    create index(:activities, [:status])

  end
end
