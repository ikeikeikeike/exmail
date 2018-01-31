defmodule Exmail.Repo.Migrations.CreateAudience do
  use Ecto.Migration

  def change do
    create table(:audiences) do
      add :user_id, :integer

      add :name, :string, comment: "Audience name"
      add :from_email, :string, comment: "Default From E-Mail address"
      add :from_name, :string, comment: "Default From name"
      add :explain, :text

      timestamps()
    end
    create index(:audiences, [:user_id])
    create index(:audiences, [:name])

  end
end
