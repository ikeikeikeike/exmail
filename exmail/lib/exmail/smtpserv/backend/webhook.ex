defmodule Exmail.SMTPServ.Backend.Webhook do
  @behaviour Exmail.SMTPServ.Backend

  alias Exmail.SMTPServ.{Parser}

  require Logger

  def send_json(data, opts \\ []) do
    endpoint = Exmail.smtp_env(:backend, :endpoint)
    headers = ["Content-Type": "application/json"]

    value = Parser.parse_mail_data(:mimemail.decode(data)) || %{}
    value = Map.merge value, %{"_bounce" => Parser.parse_bounce_data(data)}

    with {:ok, json} <- Poison.encode(value),
         {:ok, %{status_code: sc} = resp} when sc >= 200 and sc < 400 <- HTTPoison.post(endpoint, json, headers) do
      {:ok, resp}
    else error ->
      Logger.warn "[handle_DATA] could not send json to webhook " <>
                  "from=#{inspect opts[:from]} to=#{inspect opts[:to]}: #{inspect error}"
      error
    end
  end

end
