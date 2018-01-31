defmodule Exmail.Repo.Migrations.CreateTemplate do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :user_id, :integer
      add :type, :string
      add :title, :string
      add :tpl, :text, comment: "template path"

      timestamps()
    end
    create index(:templates, [:user_id])
    create index(:templates, [:type])
    create index(:templates, [:title])

  end
end
