defmodule Exmail.Service.Subscribers do
  import Ecto.Query

  alias Exmail.{Repo, Subscriber, Audience, AudienceSubscriber}

  def attend_audience(conn, %{"email" => email} = params) do
    subscriber = Repo.get_by(Subscriber, email: email) || %Subscriber{}
    params     = Map.merge params, %{"id" => subscriber.id}

    # Add user to Subscriber which this is all of subscribers from launched service until now.
    changeset  = Subscriber.changeset subscriber, params
    case Repo.insert_or_update(changeset) do
      {:ok, subscriber} ->
        # Add relation to AudienceSubscriber
        conn.assigns.audience
        |> Audience.rel_changeset(subscriber)
        |> Repo.insert_or_update

        {:ok, subscriber}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Latest update profile to subscriber. Those are updating that there's geocode, language, mailer, etc..
  """
  def latest_update(%AudienceSubscriber{} = ausubs, params) do
    changeset = AudienceSubscriber.changeset ausubs, params

    case Repo.update(changeset) do
      {:ok, ausubs} ->
        # Update to Subscriber
        from(q in Subscriber, where: q.id == ^(ausubs.subscriber_id))
        |> Repo.update_all([set: kw(params) ++ [updated_at: ausubs.updated_at]])

        {:ok, ausubs}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp kw(kvlist) do
    for {k, v} <- kvlist, into: [] do
      {:"#{k}", v}
    end
  end

end
