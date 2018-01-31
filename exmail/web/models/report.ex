defmodule Exmail.Report do
  use Exmail.Web, :model

  alias Exmail.{User, Campaign, Activity}

  schema "reports" do
    belongs_to :user, User
    belongs_to :campaign, Campaign

    has_many :activities, Activity

    timestamps()
  end

  @requires ~w(user_id campaign_id)a
  @castable ~w(user_id campaign_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @requires)
    |> validate_required(@castable)
  end

  def with_summary(queryable \\ __MODULE__) do
    from q in queryable,
      preload: [
        :user,
        campaign: [
          # Three layeres' relational query. take care performance.
          audience: :subscribers,
        ]
      ]
  end

  def with_types(queryable \\ __MODULE__) do
    # TODO: distinct: true,
    from q in queryable,
      join: j in assoc(q, :campaign),
      left_join: a in assoc(j, :abtesttypes),
      left_join: r in assoc(j, :regulartype),
      left_join: t in assoc(j, :texttype),
      where: is_nil(a.campaign_id)
          or is_nil(r.campaign_id)
          or is_nil(t.campaign_id),
      preload: [
        # Three layeres' relational query. take care performance.
        campaign: ^(Campaign.reltypes)
      ]
  end

end
