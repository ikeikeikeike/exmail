defmodule Exmail.Activity do
  use Exmail.Web, :model

  alias Exmail.{Report, Campaign, Audience, Subscriber}

  defmodule Status do
    import EctoEnum
    defenum Enum,
      sent: 0,
      open: 1,
      click: 2,
      soft_bounce: 3,
      hard_bounce: 4,
      bounce: 5,  # This status is undetected bounce status
      unsubscribe: 6,
      complain: 7
  end

  defmodule ActivityLink do
    use Exmail.Web, :model
    schema "activities_links" do
      field :link, :string  # has_many :activities, Exmail.Activity  # Comment in if wants
    end
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:link])
      |> validate_required([:link])
      |> validate_format(:link, ~r/http/)
    end
  end

  schema "activities" do
    belongs_to :report, Report
    belongs_to :campaign, Campaign
    belongs_to :audience, Audience
    belongs_to :subscriber, Subscriber
    belongs_to :activity_link, ActivityLink
    # belongs_to :audience_subscriber, AudienceSubscriber

    field :status, Status.Enum
    field :count, :integer, virtual: true
    field :timestamp, :utc_datetime

    timestamps()
  end

  @requires ~w()a
  @castable ~w(
    report_id campaign_id audience_id subscriber_id activity_link_id
    status timestamp
  )a  # audience_subscriber_id

  @statuses Keyword.keys(Status.Enum.__enum_map__)
  def statuses, do: @statuses

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> validate_inclusion(:status, @statuses)
  end

  def with_subscriber(queryable \\ __MODULE__) do
    from q in queryable,
      preload: [
        :subscriber,
      ]
  end

  def with_activity(queryable \\ __MODULE__) do
    from q in queryable,
      preload: [
        :campaign,
        :audience,
        :activity_link,
      ]
  end

  def aggs_status do
    from q in __MODULE__,
      group_by: [
        q.status,
        q.subscriber_id,
        q.report_id,
        q.campaign_id,
        q.audience_id,
      ],
      select: %{
        count: count(q.id),
        status: q.status,
        subscriber_id: q.subscriber_id,
        report_id: q.report_id,
        campaign_id: q.campaign_id,
        audience_id: q.audience_id,
      },
      order_by: [desc: count(q.id)]
  end

  def aggs_mostly(report_id) do
    from q in __MODULE__,
      join: j in Subscriber,
      select: %{
        audience_id: q.audience_id,
        subscriber_id: j.id,
        email: j.email,
        status: q.status,
        count: count(q.status)
      },
      group_by: [q.status, q.audience_id, q.subscriber_id],
      where: q.report_id == ^report_id
         and q.subscriber_id == j.id
         and q.status in ^[:open, :click],
      order_by: [desc: count(q.status)],
      limit: 5
  end

  def aggs_total_links(report_id) do
    base =
      from q in __MODULE__,
        group_by: [q.activity_link_id, q.subscriber_id],
        where: q.report_id == ^(report_id)

    queryable = from q in base, select: %{
      activity_link_id: q.activity_link_id,
      count: count(q.activity_link_id)
    }

    from q in subquery(queryable),
      join: j in ActivityLink,
      where: q.activity_link_id == j.id,
      group_by: q.activity_link_id,
      select: {j.link, sum(q.count)}
  end

end
