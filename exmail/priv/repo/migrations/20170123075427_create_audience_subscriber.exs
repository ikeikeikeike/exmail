defmodule Exmail.Repo.Migrations.CreateAudienceSubscriber do
  use Ecto.Migration

  def change do
    create table(:audiences_subscribers, comment: "Unuses audiences_subscribers.id as primary key") do
      add :audience_id, references(:audiences), comment: "Composite primary key with subscriber_id"
      add :subscriber_id, references(:subscribers), comment: "Composite primary key with audience_id"

      add :email, :string
      add :last_name, :string
      add :first_name, :string

      timestamps()
    end
    create index(:audiences_subscribers,  [:audience_id, :subscriber_id], unique: true)
    create index(:audiences_subscribers,  [:subscriber_id, :audience_id], unique: true)
    create index(:audiences_subscribers,  [:email])

  end

end
