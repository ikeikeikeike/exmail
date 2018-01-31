defmodule Exmail.Campaign.Texttype do
  use Exmail.Web, :model
  use Arc.Ecto.Schema
  use Exmail.Concerns.Campaign.CampaignType

  alias Exmail.{Campaign, TemplateUploader}

  track_open false
  track_html_click false
  track_text_click true

  schema "texttypes" do
    many_to_many :images, Exmail.Image, join_through: "texttypes_images",
      on_delete: :delete_all, on_replace: :delete

    belongs_to :campaign, Campaign

    field :from_email, :string
    field :from_name, :string

    field :subject, :string
    field :tpl, TemplateUploader.Type
    field :alt, :string, virtual: true  # Alternative tpl that uses as fallback

    field :schedule, :utc_datetime

    timestamps()
  end

  @attaches ~w(tpl)a
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

end
