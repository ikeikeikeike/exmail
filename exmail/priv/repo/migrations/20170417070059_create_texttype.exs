defmodule Exmail.Repo.Migrations.CreateTexttype do
  use Ecto.Migration

  def change do
    create table(:texttypes) do
      add :campaign_id, :integer

      add :from_email, :string
      add :from_name, :string

      add :subject, :string
      add :tpl, :text, comment: "template path"

      timestamps()
    end
    create index(:texttypes, [:campaign_id])

  end
end
