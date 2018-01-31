defmodule Exmail.CampaignTest do
  use Exmail.ModelCase

  alias Exmail.Campaign

  @valid_attrs %{from_email: "some content", from_name: "some content", name: "some content", subject: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @invalid_attrs)
    refute changeset.valid?
  end
end
