defmodule Exmail.Mailbox do
  use Exmail.Web, :model

  schema "mailboxes" do
    belongs_to :user, Exmail.User

    has_one :receipt, Exmail.MailboxReceipt

    field :type, :string
    field :subject, :string, default: ""
    field :body, :string
    field :attachment, :string
    field :draft, :boolean, default: false
    field :global, :boolean, default: false
    field :notification_code, :string, default: nil
    field :expires, :utc_datetime

    timestamps()
  end

  @requires ~w(
    type body
  )a

  @castable ~w(
    user_id type subject body draft
    attachment notification_code global expires
  )a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end
end
