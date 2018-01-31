defmodule Exmail.ImageTest do
  use Exmail.ModelCase

  alias Exmail.Image

  @valid_attrs %{assoc_id: 42, src: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Image.changeset(%Image{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Image.changeset(%Image{}, @invalid_attrs)
    refute changeset.valid?
  end
end
