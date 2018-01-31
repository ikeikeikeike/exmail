defmodule Exmail.Service.Tpl do

  alias Exmail.{Repo, Template, TemplateUploader, Hash}

  @doc """
  Enable transaction for uploads template using arc module that need to get
  secuence id from database.
  """
  def create(%{"user_id" => _, "tpl" => _} = params) do
    {user_id, uparams} = Map.pop params, "user_id"

    Repo.transaction fn ->
      with {:ok, template}  <- Repo.insert(Template.changeset(%Template{}, %{"user_id" => user_id})),
           {:ok, template}  <- Repo.update(Template.tpl_changeset(template, uparams)) do
        template
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end
  end
  def create(%{"user_id" => _, "paste" => paste} = params) do
    tpl = %Plug.Upload{
      path: Exmail.File.store_temporary(paste),
      content_type: "text/html",
      filename: "#{Hash.randstring(10)}.html",
    }

    create Map.merge(params, %{"tpl" => tpl})
  end

  def copy(src, %{"user_id" => _} = params) do
    {user_id, uparams} = Map.pop params, "user_id"

    Repo.transaction fn ->
      with {:ok, dest}      <- Repo.insert(Template.changeset(%Template{}, %{"user_id" => user_id})),
           {:ok, template}  <- Repo.update(Template.copy_changeset(dest, src, uparams)) do
        template
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end
  end

  def update_stored(struct, %{"body" => body}, uploader \\ &TemplateUploader.store/1) do
    upfile = %Plug.Upload{
      path: Exmail.File.store_temporary(body),
      filename: struct.tpl.file_name,
    }

    uploader.({upfile, struct})
  end

end
