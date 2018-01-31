defmodule Exmail.RegulartypeTest do
  use Exmail.ModelCase

  alias Exmail.Regulartype

  @valid_attrs %{campaign_id: 42, from_email: "some content", from_name: "some content", subject: "some content", tpl: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Regulartype.changeset(%Regulartype{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Regulartype.changeset(%Regulartype{}, @invalid_attrs)
    refute changeset.valid?
  end
end
