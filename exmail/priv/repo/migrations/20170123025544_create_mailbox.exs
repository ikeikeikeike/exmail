defmodule Exmail.Repo.Migrations.CreateMailbox do
  use Ecto.Migration

  # recently unuses
  def change do
    create table(:mailboxes) do
      add :user_id, :integer

      add :type, :string
      add :subject, :string, default: ""
      add :body, :text
      add :draft, :boolean, default: false
      add :attachment, :string
      add :notification_code, :string, default: nil
      add :global, :boolean, default: false
      add :expires, :utc_datetime

      timestamps()
    end

    create index(:mailboxes, [:user_id])

  end
end
