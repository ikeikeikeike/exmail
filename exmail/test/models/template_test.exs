defmodule Exmail.TemplateTest do
  use Exmail.ModelCase

  alias Exmail.Template

  @valid_attrs %{data_uri: "some content", title: "some content", tpl: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Template.changeset(%Template{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Template.changeset(%Template{}, @invalid_attrs)
    refute changeset.valid?
  end
end
