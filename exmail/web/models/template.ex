defmodule Exmail.Template do
  use Exmail.Web, :model
  use Arc.Ecto.Schema

  alias Exmail.{User, TemplateUploader}

  schema "templates" do
    many_to_many :images, Exmail.Image, join_through: "templates_images",
      on_delete: :delete_all, on_replace: :delete

    belongs_to :user, User

    field :type, :string
    field :title, :string
    field :tpl, TemplateUploader.Type

    timestamps()
  end

  @attaches ~w(tpl)a
  @requires ~w(user_id)a
  @castable ~w(user_id type title)a
  @tpltypes ~w(Seeds Basic Themes CodeYourOwn)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> validate_inclusion(:type, @tpltypes)
  end

  def copy_changeset(struct, src, params \\ %{}) do
    arc    = Arc.File.new TemplateUploader.develop_url({src.tpl, src})
    params = Map.merge params, %{
      "tpl" => %Plug.Upload{
        path: arc.path,
        filename: arc.file_name,
      }
    }

    struct
    |> cast_attachments(params, @attaches)
    |> changeset(params)
  end

  def tpl_changeset(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, @attaches)
    |> changeset(params)
  end

  @doc """
  Prepare for save image in child table.
  """
  def image_changeset(template, %Exmail.Image{} = image) do
    params = %{
      "image_id" => image.id,
      "template_id" => template.id,
    }

    module = __MODULE__.Image
    module.changeset(struct(module), params)
  end

  @doc """
  For command line in deployment:

    $ mix run priv/repo/seeds.exs

  """
  def seeds_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> cast_attachments(params, @attaches)
    |> validate_inclusion(:type, @tpltypes)
  end

  defmodule Image do
    use Exmail.Web, :model

    alias Exmail.{Campaign.Template}

    @primary_key false
    schema "templates_images" do
      belongs_to :template, Template, define_field: false
      belongs_to :image, Exmail.Image, define_field: false

      field :template_id, :integer, primary_key: true
      field :image_id, :integer, primary_key: true

      timestamps()
    end

    @requires ~w(template_id image_id)a
    @castable ~w(template_id image_id)a

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, @castable)
      |> validate_required(@requires)
      |> unique_constraint(:template_id, name: :templates_images_template_id_image_id_index)
      |> unique_constraint(:image_id, name: :templates_images_image_id_template_id_index)
    end
  end
end
