defmodule Exmail.Router do
  use Exmail.Web, :router

  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    # plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json", "image", "html"]  # XXX: Add image accepts?
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated, handler: Exmail.ErrorController
    plug Exmail.Plug.CurrentUser
  end

  scope "/", Exmail do
    pipe_through [:api]
  end

  scope "/", Exmail do
    pipe_through [:browser, :browser_auth]

    get     "/", PageController, :index
    delete  "/logout", AuthController, :logout
    get     "/credentials", AuthController, :credentials
    get     "/signup", SignupController, :new
  end

  scope "/auth", Exmail do
    pipe_through [:browser, :browser_auth]

    get     "/:identity", AuthController, :login
    get     "/:identity/callback", AuthController, :callback
    post    "/:identity/callback", AuthController, :callback
  end

  scope "/", Exmail do
    pipe_through [:browser, :browser_auth, :login_required]
  end

  scope "/campaigns", Exmail do
    pipe_through [:browser, :browser_auth, :login_required]

    get     "/", CampaignController, :index
    post    "/distribute", CampaignController, :distribute
    get     "/distribute", CampaignController, :distribute
    put     "/distribute", CampaignController, :distribute
    delete  "/cancel_email", CampaignController, :cancel_email
  end

  scope "/templates", Exmail do
    pipe_through [:browser, :browser_auth, :login_required]

    post    "/import", TemplateController, :import
    post    "/upload", TemplateController, :upload

    resources "/", TemplateController
  end

  scope "/audiences", Exmail do
    pipe_through [:browser, :browser_auth, :login_required]

    get     "/:audience_id/subscribers/new", SubscriberController, :new
    get     "/:audience_id/subscribers/import", SubscriberController, :import
    post    "/:audience_id/subscribers/import", SubscriberController, :import

    get     "/:audience_id/subscribers/sync", SubscriberController, :sync
    post    "/:audience_id/subscribers/sync", SubscriberController, :sync

    delete  "/:audience_id/subscribers/:subscriber_id", SubscriberController, :delete_relation
    get     "/:audience_id/subscribers/:subscriber_id", SubscriberController, :show
    get     "/:audience_id/subscribers/:subscriber_id/activity", SubscriberController, :show_activity
    get     "/:audience_id/subscribers/:subscriber_id/note", SubscriberController, :show_note

    get     "/:audience_id/subscribers", SubscriberController, :index
    post    "/:audience_id/subscribers", SubscriberController, :create
    delete  "/:audience_id/subscribers", SubscriberController, :delete_relation

    resources "/", AudienceController
  end

  scope "/reports", Exmail do
    pipe_through [:browser, :browser_auth, :login_required]

    get     "/:report_id/overview", ReportController, :overview
    get     "/:report_id/view-email", ReportController, :view_email
    get     "/:report_id/links", ReportController, :links
    get     "/:report_id/activity/sent", ReportController, :activity_sent
    get     "/:report_id/activity/open", ReportController, :activity_open
    get     "/:report_id/activity/open/:audience_id/:subscriber_id", ReportController, :activity_open_subscriber
    get     "/:report_id/activity/click", ReportController, :activity_click
    get     "/:report_id/activity/click/:audience_id/:subscriber_id", ReportController, :activity_click_subscriber
    get     "/:report_id/activity/bounce", ReportController, :activity_bounce

    resources "/", ReportController, only: [:index]
  end

  #scope "/audiences", Exmail do
  #  pipe_through [:browser, :browser_auth]

  #  get "/", AudienceController, :index
  #  get "/new", AudienceController, :new
  #end

  # TODO: These endpoints have to port to Golang system or OpenResty(Redis) system someday.
  scope "/api", Exmail.Api, as: "api" do
    pipe_through [:api]

    get     "/track/:campaign/:email/o", TrackController, :open
    get     "/track/:campaign/:email/hc", TrackController, :html_click
    get     "/track/:campaign/:email/tc", TrackController, :text_click
  end

  scope "/-", Exmail.Api, as: "shorten" do
    pipe_through [:api]

    get     "/:campaign/:email/o", TrackController, :open
    get     "/:campaign/:email/hc", TrackController, :html_click
    get     "/:campaign/:email/tc", TrackController, :text_click
  end

  # Allows you to view all delivered emails.
  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end


end
