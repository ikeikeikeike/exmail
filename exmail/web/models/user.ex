defmodule Exmail.User do
  use Exmail.Web, :model

  schema "users" do
    has_many :mailboxes, Exmail.Mailbox
    has_many :authorizations, Exmail.Authorization

    has_many :campaigns, Exmail.Campaign
    has_many :audiences, Exmail.Audience

    field :email, :string

    timestamps()
  end

  @castable ~w(email)a
  @required ~w(email)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/, message: gettext("Email format is not valid"))
    |> unique_constraint(:email)
  end

  # for user_from_auth.ex
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
  end

end
