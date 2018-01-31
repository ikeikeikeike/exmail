defmodule Exmail.Repo.Migrations.CreateRegulartype do
  use Ecto.Migration

  def change do
    create table(:regulartypes) do
      add :campaign_id, :integer

      add :from_email, :string
      add :from_name, :string

      add :subject, :string
      add :tpl, :text, comment: "template path"

      timestamps()
    end
    create index(:regulartypes, [:campaign_id])

  end
end
