defmodule Exmail.Repo.Migrations.CreateTemplateImage do
  use Ecto.Migration

  def change do
    create table(:templates_images, primary_key: false) do
      add :template_id, :integer, primary_key: true
      add :image_id, :integer, primary_key: true

      timestamps()
    end
    create index(:templates_images,  [:template_id, :image_id], unique: true)
    create index(:templates_images,  [:image_id, :template_id], unique: true)

  end

end
