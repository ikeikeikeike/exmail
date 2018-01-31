defmodule Exmail.Repo.Migrations.AddBouncemsgIntoSubscriberTables do
  use Ecto.Migration

  def change do
    alter table(:audiences_subscribers) do
      add :bouncemsg, :string, comment: "Latest bounce message(reason)"
    end

    alter table(:subscribers) do
      add :bouncemsg, :string, comment: "Latest bounce message(reason)"
    end
  end
end
