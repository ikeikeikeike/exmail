defmodule Exmail.Repo.Migrations.CreateTexttypeImage do
  use Ecto.Migration

  def change do
    create table(:texttypes_images, primary_key: false) do
      add :texttype_id, :integer, primary_key: true
      add :image_id, :integer, primary_key: true

      timestamps()
    end
    create index(:texttypes_images,  [:texttype_id, :image_id], unique: true)
    create index(:texttypes_images,  [:image_id, :texttype_id], unique: true)

  end
end
