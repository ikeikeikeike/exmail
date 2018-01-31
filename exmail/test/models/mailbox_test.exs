defmodule Exmail.MailboxTest do
  use Exmail.ModelCase

  alias Exmail.Mailbox

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Mailbox.changeset(%Mailbox{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Mailbox.changeset(%Mailbox{}, @invalid_attrs)
    refute changeset.valid?
  end
end
