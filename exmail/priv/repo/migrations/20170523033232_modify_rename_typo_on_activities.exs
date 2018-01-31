defmodule Exmail.Repo.Migrations.ModifyRenameTypoOnActivities do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE activities CHANGE COLUMN activitie_link_id activity_link_id INT(11)"

    drop   index(:activities, [:activitie_link_id])
    create index(:activities, [:activity_link_id])
  end

  def down do
    execute "ALTER TABLE activities CHANGE COLUMN activity_link_id activitie_link_id INT(11)"

    drop   index(:activities, [:activity_link_id])
    create index(:activities, [:activitie_link_id])
  end

end
