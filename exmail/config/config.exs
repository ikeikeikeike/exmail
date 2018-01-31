# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

domain = System.get_env("EXMAIL_DOMAIN") || "${EXMAIL_DOMAIN}"

# General application configuration
config :exmail,
  ecto_repos: [Exmail.Repo]

# Configures the endpoint
config :exmail, Exmail.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hQ/pSJAnz7CGcuzJ8spIDosey38qJj9KkHn+k+Kd53T//JYJ+xcQ0qKlHZHn4WHu",
  render_errors: [view: Exmail.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Exmail.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, :debug_logger,
  level: :debug,
  truncate: 8192_000,
  path: "/tmp/debug_logger.log",
  format: "$date $time [$level] $levelpad$node $metadata $message ",
  metadata: [:module, :line, :function]

config :logger, :exsyslog_error,
  level: :error,
  format: "$date $time [$level] $levelpad$node $metadata $message ",
  metadata: [:module, :line, :function],
  ident: "exmail",
  facility: :local0,
  option: [:pid, :cons]

config :logger, :exsyslog_debug,
  level: :debug,
  format: "$date $time [$level] $message ",
  ident: "Exmail",
  facility: :local1,
  option: [:pid, :perror]

config :logger, :exsyslog_json,
  level: :debug,
  format: "$message ",
  formatter: ExSyslog.JsonFormatter,
  metadata: [:module, :line, :function],
  ident: "Exmail",
  facility: :local1,
  option: :pid

config :exmail, Exmail.Gettext,
  default_locale: "ja"

config :guardian, Guardian,
  issuer: "Exmail.#{Mix.env}",
  verify_issuer: true,
  ttl: {30, :days},
  serializer: Exmail.Guardian.GuardianSerializer,
  secret_key: to_string(Mix.env),
  hooks: GuardianDb,
  permissions: %{
    default: [
      :read_profile,
      :write_profile,
      :read_token,
      :revoke_token,
    ],
  }

config :guardian_db, GuardianDb,
  repo: Exmail.Repo,
  sweep_interval: 120 # 120 minutes

config :ex_aws,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  region: System.get_env("AWS_REGION") || {:system, "AWS_REGION"},
  s3: [
    scheme: "http://",
    region: System.get_env("AWS_REGION") || {:system, "AWS_REGION"}
    # host: "s3.ap-northeast-1.amazonaws.com",
  ]

config :scrivener_html,
  routes_helper: Exmail.Router.Helpers

config :exmail, :additional_mail,
  bounce: "bounce@#{domain}",
  from: "noreply@#{domain}",
  bcc: []

config :exmail, :env,
  Mix.env

config :exmail, :smtp_opts,
  port: 2525,
  sessionoptions: [callbackoptions: [parse: true]],
  # backend: [
    # provider: :webhook,
    # endpoint: "http://127.0.0.1:4000/noname",
  # ]
  backend: [
    provider: :redis,
    endpoint: "redis://127.0.0.1:6379/7"
  ]


# config :ssl,
  # protocol_version: :"tlsv1.2"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "schedule.#{Mix.env}.exs"
import_config "#{Mix.env}.exs"
