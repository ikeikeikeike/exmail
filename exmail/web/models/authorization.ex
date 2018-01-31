defmodule Exmail.Authorization do
  use Exmail.Web, :model

  schema "authorizations" do
    belongs_to :user, Exmail.User

    field :provider, :string
    field :uid, :string
    field :token, :string
    field :refresh_token, :string
    field :expires_at, :integer
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @castable ~w(user_id provider uid token refresh_token expires_at)a
  @required ~w(user_id provider uid token)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @castable)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:authorizations_provider_uid_index)
  end
end
