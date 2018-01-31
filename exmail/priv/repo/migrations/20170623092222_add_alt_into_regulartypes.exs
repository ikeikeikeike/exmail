defmodule Exmail.Repo.Migrations.AddAltIntoRegulartypes do
  use Ecto.Migration

  def change do
    alter table(:regulartypes) do
      add :alt, :text, comment: "alternative template path"
    end

  end
end
