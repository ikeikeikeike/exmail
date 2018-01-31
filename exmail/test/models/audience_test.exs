defmodule Exmail.AudienceTest do
  use Exmail.ModelCase

  alias Exmail.Audience

  @valid_attrs %{email_from: "some content", explain: "some content", name: "some content", name_from: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Audience.changeset(%Audience{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Audience.changeset(%Audience{}, @invalid_attrs)
    refute changeset.valid?
  end
end
