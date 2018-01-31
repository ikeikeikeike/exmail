defmodule Exmail.Campaign.ABTesttype do
  use Exmail.Web, :model
  use Arc.Ecto.Schema
  use Exmail.Concerns.Campaign.CampaignType

  alias Exmail.{Campaign, TemplateUploader, AlternativeUploader}

  track_open true
  track_html_click true
  track_text_click true

  schema "abtesttypes" do
    many_to_many :images, Exmail.Image, join_through: "abtesttypes_images",
      on_delete: :delete_all, on_replace: :delete

    belongs_to :campaign, Campaign

    field :from_email, :string
    field :from_name, :string

    field :subject, :string
    field :tpl, TemplateUploader.Type
    field :alt, AlternativeUploader.Type  # Alternative tpl that uses as fallback

    field :schedule, :utc_datetime

    timestamps()
  end

  @attaches ~w(tpl alt)a
  @castable ~w(campaign_id from_email from_name subject schedule)a
  @requires ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
    |> cast_attachments(params, @attaches)
  end

  @doc """
  The number three(0..2) which tries to testing in abtest.
  """
  def trials(tries \\ 3) do
    Enum.map 1..tries, fn _ -> %__MODULE__{} end
  end

end
