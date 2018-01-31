defmodule Exmail.Audience do
  use Exmail.Web, :model

  alias Exmail.{Subscriber, AudienceSubscriber}

  schema "audiences" do
    belongs_to :user, Exmail.User

    has_many :campaigns, Exmail.Campaign
    has_many :subscribers, Exmail.AudienceSubscriber

    # This relation usual unuse due to define 'has_many :subscribers' definition.
    # But it gonna be useful for aggregation.
    many_to_many :latest_subscribers, Exmail.Subscriber, join_through: "audiences_subscribers",
      on_delete: :delete_all, on_replace: :delete

    field :name, :string
    field :from_email, :string  # Default From E-Mail address
    field :from_name, :string   # Default From name
    field :explain, :string

    timestamps()
  end

  @requires ~w(name)a
  @castable ~w(user_id name from_email from_name explain)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end

  @rel_fields ~w(
    email last_name first_name
    mailer latlon language timezone
  )a
  def rel_fields, do: @rel_fields

  def rel_changeset(%__MODULE__{} = struct, %Subscriber{} = child) do
    taken  = Map.take child, @rel_fields
    params = Map.merge taken, %{
      audience_id: struct.id,
      subscriber_id: child.id,
    }

    %AudienceSubscriber{}
    |> AudienceSubscriber.changeset(params)
  end
end
