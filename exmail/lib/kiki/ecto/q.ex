defmodule Exmail.Ecto.Q do
  alias Exmail.Repo

  import Ecto.Query, only: [from: 2]

  def get_or_create(module, condition) do
    case get_or_changeset(module, condition) do
      %Ecto.Changeset{} = changeset ->
        case Repo.insert(changeset) do
          {:ok, model} ->
            {:new, model}

          otherwise ->
            otherwise
        end

      model ->
        {:ok, model}
    end
  end

  def get_or_changeset(%{} = struct, conditions) when is_list(conditions),
    do: Enum.map conditions, &get_or_changeset(struct, &1)
  def get_or_changeset(%{} = struct, condition) do
    case Repo.get_by(struct.__struct__, condition) do
      nil ->
        apply struct.__struct__, :changeset, [struct, condition]
      model ->
        model
    end
  end
  def get_or_changeset(module, condition),
    do: get_or_changeset struct(module), condition

  def exists?(queryable) do
    query =
      from(x in queryable, limit: 1)
      |> Ecto.Queryable.to_query

    case Repo.all(query) do
      [] -> false
      _  -> true
    end
  end

end
