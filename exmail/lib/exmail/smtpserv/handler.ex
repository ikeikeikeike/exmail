defmodule Exmail.SMTPServ.Handler do
  defmodule State do
    defstruct options: []
  end
  @moduledoc """

  ## callbacks

      -callback code_change(OldVsn :: any(), State :: state(), Extra :: any()) ->  {'ok', state()}.
      -callback handle_HELO(Hostname :: binary(), State :: state()) -> {'ok', pos_integer(), state()} | {'ok', state()} | error_message().
      -callback handle_EHLO(Hostname :: binary(), Extensions :: list(), State :: state()) -> {'ok', list(), state()} | error_message().
      -callback handle_MAIL(From :: binary(), State :: state()) -> {'ok', state()} | {'error', string(), state()}.
      TODO: -callback handle_MAIL_extension(Extension :: binary(), State :: state()) -> {'ok', state()} | 'error'.
      -callback handle_RCPT(To :: binary(), State :: state()) -> {'ok', state()} | {'error', string(), state()}.
      TODO: -callback handle_RCPT_extension(Extension :: binary(), State :: state()) -> {'ok', state()} | 'error'.
      -callback handle_DATA(From :: binary(), To :: [binary(),...], Data :: binary(), State :: state()) -> {'ok', string(), state()} | {'error', string(), state()}.
      -callback handle_RSET(State :: state()) -> state().
      -callback handle_VRFY(Address :: binary(), State :: state()) -> {'ok', string(), state()} | {'error', string(), state()}.
      -callback handle_other(Verb :: binary(), Args :: binary(), state()) -> {string() | 'noreply', state()}.

  ### ERROR CODES: http://www.greenend.org.uk/rjk/tech/smtpreplies.html

  """
  @behaviour :gen_smtp_server_session

  @type error_message :: {:error, String.t, State.t}

  alias Exmail.SMTPServ.{Func, Backend}

  require Logger

  @doc """
  Every time a mail arrives, a process is started is kicked started to handle it.
  The init/4 function accepts the following args

    * hostname - the SMTP server's hostname
    * session_count - number of mails currently being handled
    * client_ip_address - IP address of the client
    * options - the `callbackoptions` passed to `:gen_smtp_server.start/2`

    Return
    * `{:ok, banner, state}` - to send `banner` to client and initializes session with `state`
    * `{:stop, reason, message}` - to exit session with `reason` and send `message` to client
  """
  @spec init(binary, non_neg_integer, tuple, list) :: {:ok, String.t, State.t} | {:stop, any, String.t}
  def init(hostname, session_count, _address, options \\ []) do
    if session_count > 100_000 do
      Logger.warn(fn -> "SMTP server connection limit exceeded" end)
      {:stop, :normal, ['421 #{hostname} is too busy to accept mail right now']}
    else
      {:ok, ['#{hostname} ESMTP EXMAIL'], %{options: options}}
    end
  end


  @doc """
  Handshake with the client

    * Return `{:ok, max_message_size, state}` if we handle the hostname
      ```
      # max_message_size should be an integer
      # For 10kb max size, the return value would look like this
      {:ok, 1024 * 10, state}
      ```

    * Return `{:error, error_message, state}` if we don't handle mail for the hostname
      ```
      # error_message must be prefixed with standard SMTP error code
      # looks like this
      554 invalid hostname
      554 Dear human from Sector-8614 we don't handle mail for this domain name
      ```
  """
  @spec handle_HELO(binary, State.t) :: {:ok, pos_integer, State.t} | {:ok, State.t} | error_message
  def handle_HELO(hostname, state) do
    :io.format("250 HELO from #{hostname}~n")
    {:ok, 655_360, state} # 640KB of max size
  end



  @doc """
  Possibility of rejecting based on _from_ address,
  accept or reject mail to incoming addresses here.
  """
  @spec handle_MAIL(binary, State.t) :: {:ok, State.t} | error_message
  def handle_MAIL(_from, state) do
    {:ok, state}
  end


  # @spec handle_MAIL_extension(binary, State.t) :: {:ok, State.t} | :error
  # def handle_MAIL_extension(exception, state) do
  #   {:ok, state}
  # end


  @doc """
  Accept receipt of mail to an email address or reject it
  Possibility of rejecting based on _to_ address.
  """
  @spec handle_RCPT(binary(), State.t) :: {:ok, State.t} | {:error, String.t, State.t}
  def handle_RCPT(_to, state) do
    {:ok, state}
  end


  # @spec handle_RCPT_extension(binary(), State.t) :: {:ok, State.t} | :error
  # def handle_RCPT_extension do
  #   {:ok, state}
  # end


  @doc """
  Getting the actual mail. all the relevant stuff is in data.
  Handle mail data. This includes subject, body, etc.
  """
  @spec handle_DATA(binary, [binary, ...], binary, State.t) :: {:ok, String.t, State.t} | {:error, String.t, State.t}
  def handle_DATA(_from, _to, "", state) do
    {:error, "552 Message too small", state}
  end

  def handle_DATA(from, to, data, state) do
    Logger.warn(fn -> "[handle_DATA] #{inspect {from, to, data, state}}" end)
    uniquekey = Func.uniquify

    # periodic ? stack ? poolboy ?
    spawn fn ->
      Backend.send_json data, from: from, to: to, key: uniquekey  # post to webhook_url or redis
    end

    {:ok, uniquekey, state}
  end

  @spec handle_EHLO(binary, list, State.t) :: {:ok, list, State.t} | error_message
  def handle_EHLO(_hostname, extensions, state) do
    {:ok, extensions, state}  # {:ok, [{'STARTTLS', true} | extensions], state}
  end


  @doc """
  Reset internal state
  """
  @spec handle_RSET(State.t) :: State.t
  def handle_RSET(state) do
    state
  end


  @doc """
  Verify address. Accept all of message right now.
  """
  @spec handle_VRFY(binary, State.t) :: {:ok, String.t, State.t} | {:error, String.t, State.t}
  def handle_VRFY(user, state) do
    {:ok, "#{user}@#{:smtp_util.guess_FQDN()}", state}  # {:error, '252 VRFY disabled by policy, just send some mail', state}
  end


  @doc """
  No other SMTP verbs are recognized
  """
  @spec handle_other(binary, binary, State.t) :: {String.t, State.t}
  def handle_other(verb, _o, state) do
    {["500 Error: command not recognized : '", verb, "'"], state}
  end


  def handle_STARTTLS(state) do
    state
  end


  def handle_info(_info, state) do
    {:noreply, state}
  end


  def code_change(_oldVsn, state, _extra) do
    {:ok, state}
  end


  @spec terminate(any, State.t) :: {:ok, any, State.t}
  def terminate(reason, state) do
    {:ok, reason, state}
  end
end
