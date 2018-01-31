# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exmail.Repo.insert!(%Exmail.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Exmail.{Repo, Template}

tbase = Path.join __DIR__, ~w(seeds / template)
templates = Path.wildcard "#{tbase}/*"

Enum.each templates, fn fpath ->
  filename = Path.basename(fpath)
  title    = String.split(filename, ".") |> List.first
  params   = %{
    type: "Seeds",
    title: title,
  }
  tplparam =  %{
    tpl: %Plug.Upload{
      content_type: MIME.from_path(fpath),
      filename: Path.basename(fpath),
      path: fpath
    }
  }

  unless Repo.get_by(Template, title: filename, type: "Seeds") do
    Repo.transaction(fn ->
      with {:ok, template} <- Repo.insert(Template.seeds_changeset(%Template{}, params)),
           {:ok, template} <- Repo.update(Template.seeds_changeset(template, tplparam)) do
        :do_nothing
      end
    end)
  end
end
