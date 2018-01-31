defmodule Exmail.Repo.Migrations.CreateMailboxReceipt do
  use Ecto.Migration

  # recently unuses
  def change do
    create table(:mailboxes_receipts) do
      add :mailboxes_id, :integer, null: false
      add :is_read, :boolean, default: false
      add :trashed, :boolean, default: false
      add :deleted, :boolean, default: false
      add :mailbox_type, :string, limit: 25

      timestamps()
    end
    create index(:mailboxes_receipts, [:mailboxes_id])

  end
end
