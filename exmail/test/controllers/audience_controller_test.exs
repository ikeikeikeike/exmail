defmodule Exmail.AudienceControllerTest do
  use Exmail.ConnCase

  alias Exmail.Audience
  @valid_attrs %{email_from: "some content", explain: "some content", name: "some content", name_from: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, audience_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing audiences"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, audience_path(conn, :new)
    assert html_response(conn, 200) =~ "New audience"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, audience_path(conn, :create), audience: @valid_attrs
    assert redirected_to(conn) == audience_path(conn, :index)
    assert Repo.get_by(Audience, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, audience_path(conn, :create), audience: @invalid_attrs
    assert html_response(conn, 200) =~ "New audience"
  end

  test "shows chosen resource", %{conn: conn} do
    audience = Repo.insert! %Audience{}
    conn = get conn, audience_path(conn, :show, audience)
    assert html_response(conn, 200) =~ "Show audience"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, audience_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    audience = Repo.insert! %Audience{}
    conn = get conn, audience_path(conn, :edit, audience)
    assert html_response(conn, 200) =~ "Edit audience"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    audience = Repo.insert! %Audience{}
    conn = put conn, audience_path(conn, :update, audience), audience: @valid_attrs
    assert redirected_to(conn) == audience_path(conn, :show, audience)
    assert Repo.get_by(Audience, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    audience = Repo.insert! %Audience{}
    conn = put conn, audience_path(conn, :update, audience), audience: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit audience"
  end

  test "deletes chosen resource", %{conn: conn} do
    audience = Repo.insert! %Audience{}
    conn = delete conn, audience_path(conn, :delete, audience)
    assert redirected_to(conn) == audience_path(conn, :index)
    refute Repo.get(Audience, audience.id)
  end
end
