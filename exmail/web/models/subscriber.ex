defmodule Exmail.Subscriber do
  @moduledoc """
  Unique subscribers on all of audiences. This module is able to remove from databse if it is necessarily.
  Because I think that it would not use this module many times by exmail system.
  """
  use Exmail.Web, :model

  schema "subscribers" do
    many_to_many :audiences, Exmail.Audience, join_through: "audiences_subscribers",
      on_delete: :delete_all, on_replace: :delete

    has_many :related_us, Exmail.AudienceSubscriber

    field :email, :string
    field :last_name, :string
    field :first_name, :string

    field :mailer, :string     # Latest-update Email-Client
    field :latlon, :string     # Latest-update location
    field :language, :string   # Latest-update language
    field :timezone, :string   # Latest-update timezone
    field :bouncemsg, :string  # Latest-update bounce message(reason)

    # field :permission, :string, default: "none"

    timestamps()
  end

  @requires ~w(email)a
  @castable ~w(email last_name first_name
               mailer latlon language timezone bouncemsg)a

  # @permission_types ~w(none loose strict)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> validate_format(:email, ~r/@/, message: gettext("Email format is not valid"))
    |> unique_constraint(:email)
  end

  def import_changeset(%Stream{} = stream) do
    Enum.map stream, fn row ->
      params = Enum.into(Enum.zip(@castable, row), %{})
      changeset %__MODULE__{}, params
    end
  end
end
