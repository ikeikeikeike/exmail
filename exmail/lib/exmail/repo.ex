defmodule Exmail.Repo do
  use Ecto.Repo, otp_app: :exmail
  use Scrivener, page_size: 33
end
