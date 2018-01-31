defmodule Exmail.Repo.Migrations.CreateCampaign do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add :user_id, :integer
      add :audience_id, :integer

      add :type, :string, comment: "Campaign type"
      add :name, :string, comment: "Campaign name"

      # This flags are no need that defiens to database, like below.
      # I think that prefers to change this field's type to json if MySQL has over version 5.7+
      add :track_open, :boolean, default: true, comment: "Tracking email open"
      add :track_text_click, :boolean, default: true, comment: "Tracking plain-text click"
      add :track_html_click, :boolean, default: true, comment: "Tracking html click"

      add :post_twitter, :boolean, default: false, comment: "After post when sent message"
      add :post_facebook, :boolean, default: false, comment: "After post when sent message"

      timestamps()
    end
    create index(:campaigns, [:user_id])
    create index(:campaigns, [:audience_id])
    create index(:campaigns, [:type])
    create index(:campaigns, [:name])
    # create index(:campaigns, [:type])

  end
end
