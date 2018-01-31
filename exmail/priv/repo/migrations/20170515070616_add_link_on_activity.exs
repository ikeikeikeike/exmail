defmodule Exmail.Repo.Migrations.AddLinkOnActivity do
  use Ecto.Migration

  # Separating url field, which means sql query improves index performance.
  def up do
    create table(:activities_links) do
      add :link, :text
    end
    execute "ALTER TABLE activities_links ADD UNIQUE activities_links_link_index(link(255));"

    alter table(:activities) do
      add :activitie_link_id, :integer
    end
    create index(:activities, [:activitie_link_id])

  end

  def down do
    drop index(:activities, [:activitie_link_id])
    alter table(:activities) do
       remove :activitie_link_id
    end

    drop table(:activities_links)
  end

end
