defmodule Exmail.MailboxReceipt do
  use Exmail.Web, :model

  schema "mailboxes_receipts" do
    belongs_to :mailbox, Exmail.Mailbox

    field :mailbox_type, :string, default: :sentbox

    field :is_read, :boolean, default: false
    field :trashed, :boolean, default: false
    field :deleted, :boolean, default: false

    timestamps()
  end

  @requires ~w()a
  @castable ~w(mailbox_id is_read trashed deleted mailbox_type)a
  # @mailbox_types ~w(sentbox)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@requires)
  end
end
