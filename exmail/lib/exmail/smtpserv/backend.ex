defmodule Exmail.SMTPServ.Backend do

  @callback send_json(data::map, opts::Keyword.t) :: {:ok, term} | {:error, term}

  defmodule Base do
    @moduledoc false

    @doc false
    defmacro __using__(_opts) do
      quote do
        @before_compile unquote(__MODULE__)
      end
    end

    defmacro __before_compile__(_env) do
      quote do
        backend = Exmail.smtp_env(:backend)
        case backend[:provider] do
          :webhook ->
            defdelegate send_json(data, opts \\ []),
              to: __MODULE__.Webhook

          :redis ->
            defdelegate send_json(data, opts \\ []),
              to: __MODULE__.Redis

          _ ->
            raise ArgumentError,
              "In :exmail :smtp_opts :backend was missing " <>
              "configuration that value is `#{inspect backend}`"
        end
      end
    end
  end

  @before_compile __MODULE__.Base

end
