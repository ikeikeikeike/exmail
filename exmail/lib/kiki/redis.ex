defmodule Exmail.Redis do
  defmodule Msgpack do
    @behaviour Rdtype.Coder

    def enc(message), do: Msgpax.pack! message, iodata: false
    def dec(message), do: Msgpax.unpack! message
  end

  defmodule Json do
    @behaviour Rdtype.Coder

    def enc(message), do: Poison.encode! message
    def dec(message), do: Poison.decode! message
  end
end
