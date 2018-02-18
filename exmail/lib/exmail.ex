defmodule Exmail do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Exmail.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Exmail.Endpoint, []),
      # Start your own worker by calling: Exmail.Worker.start_link(arg1, arg2, arg3)
      # worker(Exmail.Worker, [arg1, arg2, arg3]),
      worker(GuardianDb.ExpiredSweeper, []),
      # Self host to smtp server
      worker(:gen_smtp_server, [Exmail.SMTPServ.Handler, [smtp_env()]]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exmail.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def parse_env({:system, env}) when is_binary(env) do
    System.get_env(env) || ""
  end
  def parse_env(env) do
    env
  end

  def smtp_env(:backend, key) do
    parse_env smtp_env()[:backend][key]
  end
  def smtp_env(key) do
    parse_env smtp_env()[key]
  end
  def smtp_env do
    Application.get_env(:exmail, :smtp_opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Exmail.Endpoint.config_change(changed, removed)
    :ok
  end
end
