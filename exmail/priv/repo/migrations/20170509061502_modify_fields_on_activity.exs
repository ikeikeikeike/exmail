defmodule Exmail.Repo.Migrations.ModifyFieldsOnActivity do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      remove :user_id

      add :campaign_id, :integer
      add :audience_id, :integer
      add :subscriber_id, :integer

      modify :status, :integer, comment: "sent: 0, open: 1, click: 2, bounce: 3, unsubscribe: 4, complain: 5, etc.."
    end
    create index(:activities, [:campaign_id])
    create index(:activities, [:audience_id])
    create index(:activities, [:subscriber_id])

  end
end
