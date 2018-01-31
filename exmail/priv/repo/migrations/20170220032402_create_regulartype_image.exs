defmodule Exmail.Repo.Migrations.CreateRegulartype do
  use Ecto.Migration

  def change do
    create table(:regulartypes_images, primary_key: false) do
      add :regulartype_id, :integer, primary_key: true
      add :image_id, :integer, primary_key: true

      timestamps()
    end
    create index(:regulartypes_images,  [:regulartype_id, :image_id], unique: true)
    create index(:regulartypes_images,  [:image_id, :regulartype_id], unique: true)

  end
end
