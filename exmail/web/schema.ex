defmodule Exmail.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      # Be able to configure default schema settings.
      # @timestamps_opts inserted_at: :created_at
    end
  end
end
