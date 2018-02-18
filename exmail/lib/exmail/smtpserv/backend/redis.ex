defmodule Exmail.SMTPServ.Backend.Redis do
  @behaviour Exmail.SMTPServ.Backend

  # Unses
  # defmodule Store do
  #   use Rdtype,
  #     uri: Exmail.smtp_env(:backend, :endpoint),
  #     type: :list
  # end

  alias Exmail.{Redis, Hash}
  alias Exmail.SMTPServ.{Parser}

  require Logger

  def send_json(data, opts \\ []) do
    with %{"X-CampaignID" => hashkey} = mail <- Parser.parse_mail_data(:mimemail.decode(data)),
          [key] <- Hash.unidify(hashkey) do

      if bounce = Parser.parse_bounce_data(data) do
        value = Map.merge mail, %{"_bounce" => bounce}
        Redis.Track.push_bounce key, value
      else
        :none # Redis.Track.push_complaint key, mail
      end
    else
      MatchError ->
        Logger.debug fn ->
          "[send_json] MatchError in Redis from=#{inspect opts[:from]} to=#{inspect opts[:to]}"
        end
      error ->
        Logger.warn fn ->
          "[send_json] could not send json to redis " <>
          "from=#{inspect opts[:from]} to=#{inspect opts[:to]}: #{inspect error}"
        end
    end
  end

end
