defmodule Exmail.CampaignView do
  use Exmail.Web, :view

  import Exmail.Func, only: [fint!: 1]

  alias Exmail.{Campaign, Audience, AlternativeUploader, TemplateUploader, Tasks, Plug.Exceptions}
  alias Exmail.Campaign.{ABTesttype, Regulartype, Texttype}

  # URL Router

  def distribute_path(conn, campaign, [_head | _tail], wizard) do
    campaign_path conn, :distribute, id: campaign.id, wizard: wizard
  end
  def distribute_path(conn, campaign, %{__struct__: _} = reltype, wizard) do
    campaign_path conn, :distribute, id: campaign.id, relid: reltype.id, wizard: wizard
  end
  def distribute_path(conn, campaign, _reltype, wizard) do
    campaign_path conn, :distribute, id: campaign.id, wizard: wizard
  end
  def distribute_path(conn, campaign, wizard) do
    campaign_path conn, :distribute, id: campaign.id, wizard: wizard
  end

  def distribute_path?(conn, campaign, [_head | _tail], wizard) do
    current_page? conn, "campaign.distribute", id: campaign.id, wizard: wizard
  end
  def distribute_path?(conn, campaign, %{__struct__: _} = reltype, wizard) do
    current_page? conn, "campaign.distribute", id: campaign.id, relid: reltype.id, wizard: wizard
  end
  def distribute_path?(conn, campaign, _reltype, wizard) do
    current_page? conn, "campaign.distribute", id: campaign.id, wizard: wizard
  end
  def distribute_path?(conn, campaign, wizard) do
    current_page? conn, "campaign.distribute", id: campaign.id, wizard: wizard
  end

  # For Templates

  def confirm_attributes(conn, %Campaign{} = camp) do
    Campaign.reltype(camp)
    |> (case do
      [_|_] = camps ->
        camps
      camp ->
        [camp]
    end)
    |> Enum.map(fn reltype ->
      confirm_attributes conn, reltype
    end)
    |> Enum.concat([tag :div])
  end

  def confirm_attributes(_conn, %{tpl: _} = reltype) do
    attrs = [
      {:data, [tpl: TemplateUploader.url({reltype.tpl, reltype})]},
      class: "confirm-config",
    ]
    attrs =
      attrs ++ if Map.has_key?(reltype, :alt) do
        [{:data, [alt: AlternativeUploader.url({reltype.alt, reltype})]}]
      else
        []
      end

    tag :p, attrs
  end

  def tinyeditor_attributes(conn, %Campaign{} = camp, reltype \\ nil) do
    reltype = reltype || Campaign.reltype camp
    attrs   = ~w(
      data-tpl=#{TemplateUploader.url {reltype.tpl, reltype}}
      data-image-host=#{static_url conn, "/images"}
      data-post-twitter=#{camp.post_twitter}
      data-post-facebook=#{camp.post_facebook}
    )

    attrs
    |> Enum.filter(& !!&1)
    |> Enum.join(" ")
  end

  def texteditor_attributes(_conn, %Campaign{} = camp) do
    reltype   = Campaign.reltype camp
    tpl   = if TemplateUploader.has_doc?({reltype.tpl, reltype}), do: TemplateUploader.url({reltype.tpl, reltype})
    attrs = [
      {:data, [tpl: tpl]},
      {:data, ["default-tpl": default_plain_text()]},
      id: "texteditor-config",
    ]

    tag :i, attrs
  end

  def timeleft(campaign) do
    reltype = Campaign.reltype campaign
    {_, diff} = Tasks.Sendmail.cancelable(reltype.schedule)
    round(if diff >= 0, do: diff - Tasks.Sendmail.cancelable_sec, else: 0)
  end

  def cancelable?(campaign) do
    reltype = Campaign.reltype campaign
    Tasks.Sendmail.cancelable? reltype.schedule
  end

  # for use both

  @wizard_prefix "distribute_"

  def index_list(conn) do
    from(
      q in Campaign,
      where: q.user_id == ^(conn.assigns.current_user.id),
      order_by: [desc: q.id]
    )
    |> Campaign.with_user
    |> Campaign.with_report
    |> Campaign.with_types
    |> Campaign.with_audience
  end

  def new_campaign(conn, audience_id \\ nil) do
    audience   = Repo.get Audience, audience_id
    from_email = audience && audience.from_email
    from_name  = audience && audience.from_name

    camp =
      case get_dvalue(conn, "type") do
        "Regular" -> %Campaign{type: "Regular", regulartype: %Regulartype{from_email: from_email, from_name: from_name}}
        "Text"    -> %Campaign{type: "Text", texttype: %Texttype{from_email: from_email, from_name: from_name}}
        "ABTest"  -> %Campaign{type: "ABTest", abtesttypes: ABTesttype.trials}
        "RSS"     -> %Campaign{type: "RSS"}
      end

    Repo.preload camp, Campaign.reltypes
  end

  def put_dvalue(conn, key, value) do
    put_session conn, "#{@wizard_prefix}#{key}", value
  end
  def get_dvalue(conn, key) do
    get_session conn, "#{@wizard_prefix}#{key}"
  end
  def del_dvalue(conn) do
    delkeys =
      conn.private.plug_session
      |> Enum.filter(fn {key, _} ->
        String.starts_with?(key, @wizard_prefix)
      end)
      |> Enum.map(fn {key, _} ->
        key
      end)

    Enum.reduce delkeys, conn, fn key, acc ->
      delete_session acc, key
    end
  end

  def reltpl(campaign) do
    case Campaign.reltype(campaign) do
      [_|_] = types ->
        Enum.map types, & &1.tpl
      type ->
        type.tpl
    end
  end

  def default_plain_text do
    """
--- ENTER YOUR CONTENT HERE, THIS IS DEFAULT CONTENT ---


==============================================
*|AUDIENCE:EXPLAIN|*

Our mailing address is:
*|AUDIENCE:ADDRESS|*

Our telephone:
*|AUDIENCE:PHONE|*
    """
  end

  defmodule AssignCampaign do
    @moduledoc """
    In a http request has id, when user doesn't have campaign,
    its gonna reject request sooner.
    """

    def init(opts), do: opts

    def call(%Plug.Conn{params: params} = conn, _opts) do
      case params do
        # Must have campaign and report
        %{"id" => id, "rid" => rid} ->
          queryable =
            from [q, j] in Campaign.with_reportable,
              where: q.id == ^fint!(id)
                 and j.id == ^fint!(rid)
                 and q.user_id == ^(conn.assigns.current_user.id)

          campaign = Repo.one! Campaign.with_types(queryable)
          conn
          |> assign(:campaign, campaign)
          |> assign(:report, campaign.report)

        # Must have campaign
        %{"id" => id} ->
          queryable =
            from [q, _j] in Campaign.with_sendable,
              where: q.id == ^fint!(id)
                 and q.user_id == ^(conn.assigns.current_user.id)

          campaign = Repo.one! Campaign.with_types(queryable)
          assign conn, :campaign, campaign

        _otherwise    ->
          conn
      end
    end
  end

  defmodule AssignCampaignType do
    @moduledoc """
    After passing a AssignCampaign through the plug, a http request has id and relid,
    when user doesn't have reltype, its gonna reject request sooner.
    """

    def init(opts), do: opts

    def call(%Plug.Conn{params: %{"id" => _, "relid" => _}, assigns: %{campaign: campaign}}, _) when is_nil(campaign) do
      raise Exceptions.NoContentError
    end

    def call(%Plug.Conn{params: %{"id" => _, "relid" => _}, assigns: %{campaign: %{type: "Regular"}}} = conn, _opts) do
      passthrough conn, Regulartype
    end
    def call(%Plug.Conn{params: %{"id" => _, "relid" => _}, assigns: %{campaign: %{type: "Text"}}} = conn, _opts) do
      passthrough conn, Texttype
    end
    def call(%Plug.Conn{params: %{"id" => _, "relid" => _}, assigns: %{campaign: %{type: "ABTest"}}} = conn, _opts) do
      passthrough conn, ABTesttype
    end

    # def call(%Plug.Conn{params: %{"id" => id}, assigns: %{campaign: %{type: "Regular"}}} = conn, _opts) do
      # fint!(id)
    # end
    # def call(%Plug.Conn{params: %{"id" => id}, assigns: %{campaign: %{type: "Text"}}} = conn, _opts) do
      # fint!(id)
    # end

    def call(conn, _opts), do: conn

    defp passthrough(%{params: %{"id" => id, "relid" => relid}} = conn, module) do
      queryable =
        from q in module,
          where: q.id == ^fint!(relid)
             and q.campaign_id == ^fint!(id)

      reltype = Repo.one! queryable
      assign conn, :reltype, reltype
    end

  end
end
