defmodule Exmail.Mixfile do
  use Mix.Project

  def project do
    [app: :exmail,
     version: version(),
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  defp version do
    v = "0.2.109"
    File.write! "VERSION", v
    v
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Exmail, []},
      applications: [
        :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
        :phoenix_ecto, :mariaex,

        :timex,
        :tzdata,

        :con_cache,
        :ecto,
        :hackney,
        :poison,
        :httpoison,

        :phoenix_html_simplified_helpers,
        # :common_device_detector,
        :chexes,
        :rdtype,

        :arc,
        :arc_ecto,
        :ex_aws,
        :sweet_xml,

        :scrivener,
        :scrivener_ecto,
        :scrivener_html,

        :bamboo,
        :bamboo_smtp,
        :gen_smtp,

        :ueberauth,
        :ueberauth_identity,
        :ueberauth_github,
        # :ueberauth_facebook, :ueberauth_google, :ueberauth_twitter, :ueberauth_slack

        :sentry,

        :exq,
        :quantum,
        :distillery,
        :guardian_db,
        # :sitemap,
      ],
      included_applications: [
        :ecto_enum,
        :exsyslog,
        :logger_file_backend,
        :syslog,
        :comeonin,
        :ex_crypto,
        :csv,
        :exactor,
        :guardian,
        :msgpax,
        :floki,
        :timex_ecto,
        :elixir_make,
        :xml_builder,
        :eiconv,
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:tzdata, "~> 0.5"},  # https://github.com/lau/tzdata/issues/9#issuecomment-285020450
      {:phoenix, "~> 1.2.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:mariaex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.13.1"},
      {:cowboy, "~> 1.0"},

      # Utility
      {:chexes, "~> 0.1"},
      {:phoenix_html_simplified_helpers, "~> 1.2"},
      # {:common_device_detector, "~> 0.3"},
      {:csv, "~> 1.4"},
      {:timex, "== 3.1.23"},
      {:msgpax, "~> 1.1"},  # unuses ?

      # Document
      {:floki, github: "philss/floki"},  # want to use attr function.

      # Memory Cache
      {:con_cache, "~> 0.12"},

      # Override below to be able to use.
      {:httpoison, "~> 0.11.2"},
      {:poison, "~> 3.0 or ~> 3.1", override: true},
      {:hackney, "~> 1.8", override: true},

      # Authenticate
      {:guardian, "~> 0.14"},
      {:guardian_db, "~> 0.8"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_identity, "~> 0.2"},
      # {:ueberauth_facebook, "~> 0.6"},
      # {:ueberauth_google, "~> 0.5"},
      {:ueberauth_github, "~> 0.4"},
      # {:ueberauth_twitter, "~> 0.2"},
      # {:ueberauth_slack, "~> 0.4"},
      # end more: https://hex.pm/packages?search=ueberauth&sort=downloads

      # Redis
      {:rdtype, "~> 0.5"},

      # Password hasher
      {:comeonin, "~> 3.1"},
      {:ex_crypto, "~> 0.4"},  # Need encrypt and decrypt.

      # DB Utility
      {:ecto_enum, "~> 1.0"},

      # fileupload
      {:arc, "~> 0.8"},
      {:arc_ecto, "~> 0.7"},
      {:ex_aws, "~> 1.1"},
      {:sweet_xml, "~> 0.6"},
      {:xml_builder, "~> 0.0.6"},

      # Mailer
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, github: "ikeikeikeike/bamboo_smtp", branch: "feature/rfc822_master"},  # {:bamboo_smtp, "~> 1.2"},

      # Pagination
      {:scrivener, "~> 2.2"},
      {:scrivener_ecto, "~> 1.1"},
      {:scrivener_html, "~> 1.5"},

      # for deployment
      {:distillery, "~> 1.3"},

      # Throw syslog
      {:logger_file_backend, "~> 0.0.10"},
      {:exsyslog, "~> 1.0"},
      {:sentry, "~> 3.0"},

      # Like crontab and background job, this module uses until single server.
      {:exq, "~> 0.9"},
      {:quantum, "~> 1.9"},

      # sitemap.xml
      # {:sitemap, "~> 0.9"},

      # Self hosting is working on which launches smtp server.
      {:gen_smtp, "~> 0.12", override: true},
      # {:eiconv, github: "mmzeeman/eiconv", compile: "make"},
      {:eiconv, "~> 1.0.0-alpha1"},

      # for development
      {:credo, "~> 0.8", only: [:dev, :test]},
  ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"],
     "sentry_recompile": ["deps.compile sentry --force", "compile"]
    ]
  end
end
