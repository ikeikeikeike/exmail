defmodule Exmail.CampaignController do
  use Exmail.Web, :controller

  alias Exmail.{Campaign, Report, Template, Service, ImageUploader, AlternativeUploader, Tasks}
  alias Exmail.CampaignView, as: ViewH
  # alias Exmail.Concerns.CampaignController, as: CtrlH

  require Logger

  plug Exmail.Plug.CurrentUser
  plug ViewH.AssignCampaign when action in [:distribute, :cancel_email]
  plug ViewH.AssignCampaignType when action in [:distribute, :cancel_email]

  @wizard_prefix "distribute_"

  def distribute(%Plug.Conn{assigns: %{campaign: _campaign}} = conn, %{"wizard" => "Sent", "rid" => _rid}, _current_user, _) do
    render conn, "#{@wizard_prefix}sent.html"
  end

  def distribute(%Plug.Conn{assigns: %{campaign: campaign}} = conn, %{"wizard" => "SendMail", "schedule" => schedule}, current_user, _) do
    params   = %{"user_id" => current_user.id, "campaign_id" => campaign.id, "schedule" => schedule}
    campaign = Repo.preload campaign, [:user, audience: [:subscribers]]

    # TODO: Email Validation.

    # do_some_verification

    with {:ok, _reltype} <- Tasks.Sendmail.reserve(campaign, params),
         {:ok, report} <- Repo.insert(Report.changeset(%Report{}, params)) do

        redirect conn, to: campaign_path(conn, :distribute, id: campaign.id, rid: report.id, wizard: "Sent")
    else
      {:error, changeset} ->
        render conn, "#{@wizard_prefix}confirm.html", changeset: changeset
      # {:error, mailerror} ->
        # render conn, "#{@wizard_prefix}confirm.html", mailerror: mailerror
    end
  end

  def distribute(%Plug.Conn{assigns: %{campaign: campaign}} = conn, %{"wizard" => "Confirm"}, _current_user, _) do
    campaign = Repo.preload campaign, audience: [:subscribers]

    conn
    |> render("#{@wizard_prefix}confirm.html", campaign: campaign)
  end

  def distribute(%Plug.Conn{assigns: %{reltype: reltype}} = conn, %{"wizard" => "SaveFallback", "body" => _body} = params, _current_user, _) do
    Service.Tpl.update_stored reltype, params, &AlternativeUploader.store/1  # Fallback
    json conn, %{msg: "ok"}
  end

  def distribute(%Plug.Conn{assigns: %{reltype: reltype}} = conn, %{"wizard" => "SaveDesign", "body" => _body} = params, _current_user, _) do
    Service.Tpl.update_stored reltype, params  # Main
    json conn, %{msg: "ok"}
  end

  def distribute(%Plug.Conn{assigns: %{reltype: reltype}} = conn, %{"wizard" => "SaveFile", "image" => datauri}, current_user, _) do
    params = %{"src" => datauri, "user_id" => current_user.id}

    Repo.transaction(fn ->
      with {:ok, image}    <- Service.Image.create(params),
           {:ok, _reltype} <- Repo.insert(Campaign.image_changeset(reltype, image)) do
        image
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end)
    |> case do
      {:ok, image} ->
        json conn, %{status: true, message: "ok", url: ImageUploader.develop_url({image.src, image})}

      {:error, changeset} ->
        errors = translate_errors(changeset) |> Enum.join("\n")
        json conn, %{status: false, message: errors}
    end
  end

  def distribute(%Plug.Conn{assigns: %{reltype: _reltype}} = conn, %{"wizard" => "Design"}, _current_user, _) do
    conn
    |> put_layout("wizard_app.html")
    |> render("#{@wizard_prefix}design.html")
  end

  def distribute(%Plug.Conn{assigns: %{campaign: campaign, reltype: reltype}} = conn, %{"wizard" => "PlainText"}, _current_user, _) do
    unless reltype.tpl do
      params = %{"body" => ViewH.default_plain_text()}
      Repo.update Campaign.tpl_changeset(campaign, reltype, params)
    end

    conn
    |> put_layout("wizard_app.html")
    |> render("#{@wizard_prefix}plaintext.html")
  end

  def distribute(%Plug.Conn{assigns: %{campaign: campaign, reltype: reltype}} = conn, %{"wizard" => "SaveTemplate"} = params, _current_user, _) do
    template  = Repo.get_by! Template, id: params["tid"]
    changeset = Campaign.tpl_changeset campaign, reltype, template

    case Repo.update changeset do
      {:ok, reltype} ->
        redirect(conn, to: campaign_path(conn, :distribute, id: campaign.id, relid: reltype.id, wizard: "Design"))

      {:error, changeset} ->
        errors = translate_errors(changeset) |> Enum.join("\n")
        conn
        |> put_flash(:error, gettext("Something went wrongs. %{msgs}", msgs: errors))
        |> redirect(to: campaign_path(conn, :distribute, id: campaign.id, wizard: "Template"))
    end
  end

  def distribute(%Plug.Conn{assigns: %{campaign: _campaign}} = conn, %{"wizard" => "Contents"}, _current_user, _) do
    conn
    |> put_layout("wider_app.html")
    |> render("#{@wizard_prefix}contents.html")
  end

  def distribute(%Plug.Conn{assigns: %{campaign: _campaign}} = conn, %{"wizard" => "Strategy"}, _current_user, _) do
    conn
    |> put_layout("wider_app.html")
    |> render("#{@wizard_prefix}strategy.html")
  end

  def distribute(%Plug.Conn{assigns: %{campaign: _campaign}} = conn, %{"wizard" => "Template"}, current_user, _) do
    templates =
      from(q in Template,
        where: q.user_id == ^(current_user.id),
        preload: :user
      ) |> Repo.all

    seeds =
      from(q in Template, where: q.type == "Seeds")
      |> Repo.all

    conn
    |> put_layout("wider_app.html")
    |> render("#{@wizard_prefix}template.html", templates: templates, seeds: seeds)
  end

  # Save recipient type to database with remeining session data.
  def distribute(conn, %{"wizard" => "SaveSetup", "campaign" => params}, _current_user, _) do
    {campaign, type, audience_id} =
      if present? params["id"] do
        campaign = Campaign |> Campaign.with_types |> Campaign.with_audience |> Repo.get!(params["id"])
        {campaign, campaign.type, campaign.audience.id}
      else
        campaign = Repo.preload %Campaign{}, Campaign.reltypes
        {campaign, ViewH.get_dvalue(conn, "type"), ViewH.get_dvalue(conn, "audience_id")}
      end

    params = Map.merge(params, %{
      "type" => type,
      "user_id" => conn.assigns.current_user.id,
      "audience_id" => audience_id,
    })

    Repo.transaction(fn ->
      with {:ok, campaign}  <- Repo.insert_or_update(Campaign.setup_changeset(campaign, params)),
           {:ok, campaign}  <- Repo.insert_or_update(Campaign.rel_changeset(campaign, params)) do
        campaign
      else
        {:error, changeset} -> Repo.rollback changeset
      end
    end)
    |> case do
      {:ok, %{type: "ABTest"} = campaign} ->
        conn
        |> ViewH.del_dvalue
        |> redirect(to: campaign_path(conn, :distribute, id: campaign.id, wizard: "Contents"))

      {:ok, %{type: "Text"} = campaign} ->
        relid = Campaign.reltype(campaign).id
        conn
        |> ViewH.del_dvalue
        |> redirect(to: campaign_path(conn, :distribute, id: campaign.id, relid: relid, wizard: "PlainText"))

      {:ok, campaign} ->
        relid = Campaign.reltype(campaign).id
        conn
        |> ViewH.del_dvalue
        |> redirect(to: campaign_path(conn, :distribute, id: campaign.id, relid: relid, wizard: "Template"))

      {:error, changeset} ->
        campaign  = ViewH.new_campaign(conn, audience_id)
        changeset = struct(changeset, [data: campaign])
        render conn, "#{@wizard_prefix}setup.html", changeset: changeset, campaign: campaign
    end
  end

  # Save recipient type to session
  def distribute(conn, %{"wizard" => "Setup", "recipient_audience" => ra} = _params, _current_user, _) do
    [recipient, audience_id] = String.split ra, "-"

    # Build changset with campaign type
    campaign  = ViewH.new_campaign conn, audience_id
    changeset = Campaign.changeset campaign

    conn
    |> ViewH.put_dvalue("recipient", recipient)  # TODO: Just to support distribution to entire audiences currently.
    |> ViewH.put_dvalue("audience_id", audience_id)
    |> render("#{@wizard_prefix}setup.html", changeset: changeset, campaign: campaign)
  end

  def distribute(%Plug.Conn{assigns: %{campaign: campaign}} = conn, %{"wizard" => "Setup", "id" => _id} = _params, _current_user, _) do
    changeset = Campaign.changeset(campaign)
    conn
    |> render("#{@wizard_prefix}setup.html", changeset: changeset, campaign: campaign)
  end

  # Save campaign type to session
  def distribute(conn, %{"wizard" => "Recipient", "type" => type} = params, _current_user, _) do
    user = Repo.preload conn.assigns.current_user, audiences: [:subscribers]

    conn
    |> ViewH.put_dvalue("type", type)
    |> render("#{@wizard_prefix}recipient.html", audiences: user.audiences)  # TODO: pagination, using list pagination
  end

  def distribute(conn, _params, _current_user, _) do
    render conn, "#{@wizard_prefix}type.html"
  end

  @doc """
  If system doesn't send email yet, this is gonna cancel send-email.
  """
  def cancel_email(%Plug.Conn{assigns: %{campaign: campaign}} = conn, _params, _current_user, _) do
    case Tasks.Sendmail.cancel(campaign) do
      {:ok, _reltype} ->
        conn
        |> put_flash(:info, gettext("Cancelled send-email successful accomplished."))
        |> redirect(to: campaign_path(conn, :index))

      {:timeover, _error} ->
        conn
        |> put_flash(:error, gettext("Time was up! Emali sent already, it hasn't cancelled."))
        |> redirect(to: campaign_path(conn, :index))

      {:error, error} ->
        Logger.error(inspect error)

        msg = gettext("There's something wrong, please make sure email's data and documentation")
        conn
        |> put_flash(:error, msg)
        |> redirect(to: campaign_path(conn, :index))
    end
  end

  def index(conn, params, _current_user, _) do
    render conn, "index.html", campaigns: Repo.paginate(ViewH.index_list(conn), params)
  end

end
