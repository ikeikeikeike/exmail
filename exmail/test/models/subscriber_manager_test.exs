defmodule Exmail.SubscriberManagerTest do
  use Exmail.ModelCase

  alias Exmail.SubscriberManager

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SubscriberManager.changeset(%SubscriberManager{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SubscriberManager.changeset(%SubscriberManager{}, @invalid_attrs)
    refute changeset.valid?
  end
end
