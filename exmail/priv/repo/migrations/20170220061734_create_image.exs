defmodule Exmail.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :user_id, :integer
      add :src, :text

      timestamps()
    end
    create index(:images,  [:user_id])

  end
end
