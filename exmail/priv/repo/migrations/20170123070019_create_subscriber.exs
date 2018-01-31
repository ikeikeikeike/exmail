defmodule Exmail.Repo.Migrations.CreateSubscriber do
  use Ecto.Migration

  def change do
    create table(:subscribers, comment: "Unique subscribers on all of audiences") do
      add :email, :string
      add :last_name, :string, comment: "Last-updates last name"
      add :first_name, :string, comment: "Last-updates first name"

      timestamps()
    end
    create unique_index(:subscribers, [:email])

  end
end
