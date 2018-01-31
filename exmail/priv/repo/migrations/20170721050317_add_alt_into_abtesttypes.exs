defmodule Exmail.Repo.Migrations.AddAltIntoAbtesttypes do
  use Ecto.Migration

  def change do
    alter table(:abtesttypes) do
      add :alt, :text, comment: "alternative template path"
    end
  end
end
