# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"c!,LW(?s=~C<}|l(c;1.X*kwC(!YM>=Do)G0xd/>`or~7_;fX0Z4|(v!1A}gn9OE"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"JL0{%8cFLJ{IUr?QC{dOvS]yB%fqSUewy!FTu;_HAB0b`5r;o(KgP,5;y8QF2>ZT"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :exmail do
  set version: current_version(:exmail)
  set commands: [
    "migrate": "rel/commands/migrate.sh",
    "migrate_useragent": "rel/commands/migrate_useragent.sh",
  ]
end

