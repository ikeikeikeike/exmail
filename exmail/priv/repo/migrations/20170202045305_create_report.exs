defmodule Exmail.Repo.Migrations.CreateReport do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :user_id, :integer
      add :campaign_id, :integer

      timestamps()
    end
    create index(:reports, [:user_id])
    create index(:reports, [:campaign_id])

  end
end
