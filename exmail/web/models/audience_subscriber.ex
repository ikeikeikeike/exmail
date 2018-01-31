defmodule Exmail.AudienceSubscriber do
  @moduledoc """
  Save m2m record to databse that this is for performance speed, therefore
  it defined into 'audience.ex' as compactly instead of creating ecto's file.

  Defines to audiences_subscribers.id as primary key on database's constraintation,
  But this module uses composite primary key between audience_id and subscriber_id.
  """
  use Exmail.Web, :model

  alias Exmail.{Audience, Subscriber}

  @primary_key false
  schema "audiences_subscribers" do
    field :audience_id, :integer, primary_key: true
    field :subscriber_id, :integer, primary_key: true
    belongs_to :audience, Audience, define_field: false
    belongs_to :subscriber, Subscriber, define_field: false

    field :id, :integer  # Unuses as primary key.

    field :email, :string
    field :last_name, :string
    field :first_name, :string

    field :mailer, :string     # Latest-update Email-Client
    field :latlon, :string     # Latest-update location
    field :language, :string   # Latest-update language
    field :timezone, :string   # Latest-update timezone
    field :bouncemsg, :string  # Latest-update bounce message(reason)

    timestamps()
  end

  @requires ~w(audience_id subscriber_id)a
  @castable ~w(audience_id subscriber_id email last_name first_name
               mailer latlon language timezone bouncemsg)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> validate_format(:email, ~r/@/, message: gettext("Email format is not valid"))
    |> unique_constraint(:audience_id, name: :audiences_subscribers_audience_id_subscriber_id_index)
    |> unique_constraint(:subscriber_id, name: :audiences_subscribers_subscriber_id_audience_id_index)
  end
end
