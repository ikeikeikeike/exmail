defmodule Exmail.Repo.Migrations.CreateABTesttype do
  use Ecto.Migration

  def change do
    create table(:abtesttypes) do
      add :campaign_id, :integer

      add :from_email, :string
      add :from_name, :string

      add :subject, :string
      add :tpl, :text, comment: "template path"

      timestamps()
    end
    create index(:abtesttypes, [:campaign_id])

  end
end
