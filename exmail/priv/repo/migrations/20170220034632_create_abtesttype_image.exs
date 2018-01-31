defmodule Exmail.Repo.Migrations.CreateABTesttypeImage do
  use Ecto.Migration

  def change do
    create table(:abtesttypes_images, primary_key: false) do
      add :abtesttype_id, :integer, primary_key: true
      add :image_id, :integer, primary_key: true

      timestamps()
    end
    create index(:abtesttypes_images,  [:abtesttype_id, :image_id], unique: true)
    create index(:abtesttypes_images,  [:image_id, :abtesttype_id], unique: true)

  end

end
