defmodule Exmail.Repo.Migrations.AddProfinfoIntoAudiencesSubscriber do
  use Ecto.Migration

  def change do
    alter table(:audiences_subscribers) do
      add :mailer, :string, comment: "Latest Email-Client"
      add :latlon, :string, comment: "Latest location"
      add :language, :string, comment: "Latest language"
      add :timezone, :string, comment: "Latest timezone"
    end
  end
end
