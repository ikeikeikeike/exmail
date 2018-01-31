defmodule Exmail.Campaign do
  use Exmail.Web, :model
  use Arc.Ecto.Schema

  alias Exmail.{Image, Template, TemplateUploader, Func, Hash}
  alias __MODULE__.{Regulartype, ABTesttype, Texttype}

  schema "campaigns" do
    has_many :abtesttypes, ABTesttype
    has_one :regulartype, Regulartype
    has_one :texttype, Texttype
    # has_one :rsstype, Rsstype
    has_one :report, Exmail.Report

    belongs_to :user, Exmail.User
    belongs_to :audience, Exmail.Audience

    field :type, :string  # Campaign Type
    field :name, :string  # Campaign Name

    field :track_open, :boolean, default: true        # Tracking email open
    field :track_html_click, :boolean, default: true  # Tracking html click
    field :track_text_click, :boolean, default: true  # Tracking plain-text click

    field :post_twitter, :boolean, default: false     # Post message to sicial media
    field :post_facebook, :boolean, default: false    # Post message to sicial media

    timestamps()
  end

  @requires ~w()a
  @castable ~w(
    user_id audience_id
    type name
    track_open track_text_click track_html_click
    post_twitter post_facebook
  )a

  @types ~w(ABTest Regular Text RSS)
  @reltypes ~w(abtesttypes regulartype texttype)a
  # @relmapping %{
  #   Regulartype => Func.thename(Regulartype),
  #   ABTesttype  => Func.thename(ABTesttype),
  # }

  @doc "returns association keys"
  def reltypes, do: @reltypes

  def reltype(%__MODULE__{} = struct, opts \\ []) do
    case struct do
      %{type: "Regular"} -> if opts[:module], do: Regulartype, else: struct.regulartype
      %{type: "ABTest"}  -> if opts[:module], do: ABTesttype, else: struct.abtesttypes
      %{type: "Text"}    -> if opts[:module], do: Texttype, else: struct.texttype
      # %{type: "RSS"}     -> if opts[:module], do: Rsstype, else: struct.rsstype
    end
  end

  def put_reltype(%__MODULE__{} = struct, reltype) do
    case struct do
      %{type: "Regular"} -> %{struct | regulartype: reltype}
      %{type: "ABTest"}  -> %{struct | abtesttypes: reltype}
      %{type: "Text"}    -> %{struct | texttype: reltype}
      %{type: "RSS"}     -> %{struct | rsstype: reltype}
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> validate_inclusion(:type, @types)
  end

  @doc """
  Prepare for save template
  """
  def tpl_changeset(%__MODULE__{type: "Text"}, %{tpl: _} = rel, params) do
    params = %{
      "tpl" => %Plug.Upload{
        path: Exmail.File.store_temporary(params["body"]),
        content_type: "text/plain",
        filename: "#{Hash.randstring(10)}.txt",
      }
    }

    rel
    |> Func.themodule(rel).changeset(params)
  end
  def tpl_changeset(%__MODULE__{type: "Regular"}, %{tpl: _} = rel, %Template{} = tpl) do
    arc    = Arc.File.new TemplateUploader.develop_url({tpl.tpl, tpl})
    params = %{
      "tpl" => %Plug.Upload{path: arc.path, filename: arc.file_name},
      "alt" => %Plug.Upload{path: arc.path, filename: arc.file_name},
    }

    rel
    |> Func.themodule(rel).changeset(params)
  end
  def tpl_changeset(%__MODULE__{type: "ABTest"}, %{tpl: _} = rel, %Template{} = tpl) do
    arc    = Arc.File.new TemplateUploader.develop_url({tpl.tpl, tpl})
    params = %{
      "tpl" => %Plug.Upload{path: arc.path, filename: arc.file_name},
      "alt" => %Plug.Upload{path: arc.path, filename: arc.file_name},
    }

    rel
    |> Func.themodule(rel).changeset(params)
  end
  def tpl_changeset(%__MODULE__{}, %{tpl: _} = rel, %Template{} = tpl) do
    arc    = Arc.File.new TemplateUploader.develop_url({tpl.tpl, tpl})
    params = %{
      "tpl" => %Plug.Upload{path: arc.path, filename: arc.file_name},
    }

    rel
    |> Func.themodule(rel).changeset(params)
  end

  # TODO: gonna be definition for ABTest reltype, which has multiple relation like 1:N relation.
  #
  # def schedule_changeset(struct, params) do
  def schedule_changeset(struct, params) do
    rel = reltype struct
    rel
    |> Func.themodule(rel).schedule_changeset(params)
  end

  @doc """
  Prepare for save image in child table.
  """
  def image_changeset(%__MODULE__{} = campaign, %Image{} = image) do
    rel    = reltype campaign
    params = %{
      "image_id" => image.id,
      "#{Func.thename(rel)}_id" => rel.id,
    }

    module = Module.concat Func.themodule(rel), "Image"
    module.changeset(struct(module), params)
  end
  def image_changeset(rel, %Image{} = image) do
    params = %{
      "image_id" => image.id,
      "#{Func.thename(rel)}_id" => rel.id,
    }

    module = Module.concat Func.themodule(rel), "Image"
    module.changeset(struct(module), params)
  end

  @doc """
  Prepare for save own model
  """
  def setup_changeset(struct, %{"type" => "Regular"} = params) do
    struct
    |> changeset(params)
    |> validate_acceptance(:track_text_click, message: gettext("please accept"))
    |> validate_acceptance(:track_html_click, message: gettext("please accept"))
  end
  def setup_changeset(struct, %{"type" => "Text"} = params) do
    struct
    |> changeset(params)
  end
  def setup_changeset(struct, %{"type" => "ABTest"} = params) do
    struct
    |> changeset(params)
  end
  def setup_changeset(struct, %{"type" => "RSS"} = params) do
    struct
    |> changeset(params)
  end

  @doc """
  Prepare for save relational models
  """
  def rel_changeset(struct, %{"type" => "Regular"} = params) do
    struct
    |> changeset(params)
    |> cast_assoc(:regulartype, required: true)
  end
  def rel_changeset(struct, %{"type" => "Text"} = params) do
    struct
    |> changeset(params)
    |> cast_assoc(:texttype, required: true)
  end
  def rel_changeset(struct , %{"type" => "ABTest"} = params) do
    struct
    |> changeset(params)
    |> cast_assoc(:abtesttypes, required: true)
  end
  def rel_changeset(struct, %{"type" => "RSS"} = params) do
    struct
    |> changeset(params)
    |> cast_assoc(:rsstype, required: true)
  end

  def with_user(queryable \\ __MODULE__) do
    from q in queryable,
      preload: :user
  end
  @doc """
  Result has campaign's child table
  """
  def with_types(queryable \\ __MODULE__) do
    from q in queryable,
      distinct: true,
      left_join: a in assoc(q, :abtesttypes),
      left_join: r in assoc(q, :regulartype),
      left_join: t in assoc(q, :texttype),
      where: is_nil(a.campaign_id)
          or is_nil(r.campaign_id)
          or is_nil(t.campaign_id),
      preload: ^@reltypes
  end
  def with_audience(queryable \\ __MODULE__) do
    from q in queryable,
      preload: :audience
  end
  def with_subscribers(queryable \\ __MODULE__) do
    from q in queryable,
      preload: [audience: [:subscribers]]
  end
  def with_report(queryable \\ __MODULE__) do
    from q in queryable,
      preload: :report
  end
  @doc """
  Before send email condition.
  """
  def with_sendable(queryable \\ __MODULE__) do
    from q in queryable,
      left_join: j in assoc(q, :report),
      where: is_nil(j.campaign_id)
  end
  @doc """
  After send email condition.
  """
  def with_reportable(queryable \\ __MODULE__) do
    from q in queryable,
      join: j in assoc(q, :report),
      preload: [
        :report, audience: [:subscribers]
      ]
  end

end
