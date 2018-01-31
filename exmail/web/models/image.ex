defmodule Exmail.Image do
  @moduledoc """
  For mail statics
  """
  use Exmail.Web, :model
  use Arc.Ecto.Schema

  alias Exmail.{Hash}

  schema "images" do
    many_to_many :retulartypes, Exmail.Image, join_through: "regulartypes_images",
      on_delete: :delete_all, on_replace: :delete
    many_to_many :abtesttypes, Exmail.Image, join_through: "abtesttypes_images",
      on_delete: :delete_all, on_replace: :delete
    many_to_many :templates, Exmail.Image, join_through: "templates_images",
      on_delete: :delete_all, on_replace: :delete

    belongs_to :user, Exmail.User

    field :src, Exmail.ImageUploader.Type

    timestamps()
  end

  @attaches ~w(src)a
  @castable ~w(user_id)a
  @requires ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end

  def src_changeset(struct, %{"src" => %Plug.Upload{}} = params) do
    struct
    |> changeset(params)
    |> cast_attachments(params, @attaches)
  end
  def src_changeset(struct, %{"src" => "data:" <> _ = datauri} = params) do
    {_, _, mime, ext, _} = Exmail.File.parse_datauri datauri

    params = Map.merge params, %{
      "src" => %Plug.Upload{
        path: Exmail.File.store_temporary(datauri, format: :image),
        content_type: mime,
        filename: "#{Hash.randstring(10)}.#{ext}",
      }
    }

    struct
    |> changeset(params)
    |> cast_attachments(params, @attaches)
  end

end
