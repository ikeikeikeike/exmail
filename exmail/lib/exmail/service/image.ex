defmodule Exmail.Service.Image do

  alias Exmail.{Repo, Image}

  @doc """
  Enable transaction for uploads template using arc module that need to get
  secuence id from database.
  """
  def create(%{"user_id" => _, "src" => _} = params) do
    Repo.transaction fn ->
      with {:ok, image}     <- Repo.insert(Image.changeset(%Image{}, params)),
           {:ok, image}     <- Repo.update(Image.src_changeset(image, params)) do
        image
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end
  end

end
