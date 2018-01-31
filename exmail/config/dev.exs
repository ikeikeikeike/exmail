use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :exmail, Exmail.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :exmail, Exmail.Endpoint,
  live_reload: [
    patterns: [
      # ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/static/.*(js|css)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

config :logger,
  level: :debug,
  backends: [
    :console,
    {ExSyslog, :exsyslog_error},
    {ExSyslog, :exsyslog_debug},
    {ExSyslog, :exsyslog_json},
    {LoggerFileBackend, :debug_logger}
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :exmail, Exmail.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "exmail_dev",
  hostname: "localhost",
  pool_size: 10

config :exmail, Exmail.Mailer,
  adapter: Bamboo.LocalAdapter

config :ueberauth, Ueberauth,
  providers: [
      # google: {Ueberauth.Strategy.Google, []},
      # facebook: {Ueberauth.Strategy.Facebook, [profile_fields: "email, name"]},
      github: {Ueberauth.Strategy.Github, [uid_field: "login"]},
      identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]},
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "GITHUB_CLIENT_ID",
  client_secret: "GITHUB_CLIENT_SECRET"

config :arc,
  storage: Arc.Storage.Local

config :exmail, :redis,
  track: "redis://127.0.0.1:6379/5"

# config :ua_inspector,
  # database_path: Path.join(File.cwd!, "config/ua_inspector")

# config :arc,
  # storage: Arc.Storage.S3, # or Arc.Storage.Local
  # bucket: "example.com",
  # asset_host: "http://s3-ap-northeast-1.amazonaws.com/example.com"

config :sentry,
  dsn: "http://none:none@127.0.0.1/1",
  use_error_logger: false,
  # enable_source_code_context: false, root_source_code_path: File.cwd!,
  environment_name: Mix.env,
  included_environments: [:prod]

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  database: 10,
  queues: [{"default", :infinite}, {"sequence", 1}],
  max_retries: 25,
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  shutdown_timeout: 5000
  # concurrency: :infinite,
