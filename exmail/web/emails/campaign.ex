defmodule Exmail.Emails.Campaign do
  @moduledoc """
  Email Headers: http://www.geocities.co.jp/Hollywood/9752/metamail.html
  """
  import Bamboo.Email
  import Chexes
  import Exmail.Router.Helpers

  alias Exmail.{Hash, Campaign, Audience, AlternativeUploader, TemplateUploader, Endpoint, Tasks}
  alias Exmail.Emails.{Tracking, Placeholder}

  @mailer "exmail"

  @additional Application.get_env(:exmail, :additional_mail)

  defp wait_for_ses_deliver do
    # 14 mails per a second is currently status in SES
    # Max Send Rate: 14 emails/second
    :timer.sleep(100)
  end

  def deliver(%Campaign{} = camp, [%{email: _, first_name: _, last_name: _} | _tail] = subscribers) do
    rel  = Campaign.reltype camp
    aud  = camp.audience
    body = File.read! Arc.File.new(TemplateUploader.develop_url({rel.tpl, rel})).path
    body =
      if Map.has_key?(rel, :alt) and present?(rel.alt) do
        fall = Arc.File.new(AlternativeUploader.develop_url({rel.alt, rel})).path
        {body, File.read! fall}
      else
        {body, nil}
      end

    spawn fn ->
      Enum.each subscribers, fn subscriber ->
        deliver camp, aud, subscriber, body

        wait_for_ses_deliver()
      end

      Tasks.AggsTracks.update camp, :sent  # Unuses exq, just call 'perform' function.
    end

    {:ok, :todo_result_here}
  end

  def deliver(%Campaign{} = camp, %Audience{} = aud, %{email: _, first_name: _, last_name: _} = subsc, {_, _} = body) do
    # rel  = Campaign.reltype camp
    # eid  = Hash.mailify subsc.email
    # cid  = Hash.mailify camp.id

    # uid  = Hash.mailify camp.user.id
    # tid  = String.capitalize @mailer

    new_email()
    |> gen_header(camp, aud, subsc, body)

    |> to(subsc.email)
    # |> bcc(@additional[:bcc])

    # XXX: To be uncomment this line if this system set any userland address,
    #      in order to go ahead it supports this article's functions.
    #      http://qiita.com/nakansuke/items/a20b37527b574d476a36#%E5%88%9D%E6%9C%9F%E8%A8%AD%E5%AE%9A
    # |> from(camp.from_email)

    # TODO: Must create strategies with `Bamboo.DeliverLaterStrategy` for adding
    #       emails to a Golang background through a processing queue such as `exq` or `toniq` module.

    |> deliver_with_nested(camp, aud, subsc, body)
  end

  # Resolve to generate email for relational data
  #
  defp deliver_with_nested(%Bamboo.Email{} = email, %{type: "Regular"} = camp, aud, subsc, {body, fall}) do
    reltype = Campaign.reltype camp

    email
    |> nested_data(reltype)
    |> html_body(gen_html_body(camp, aud, subsc, body))
    |> text_body(gen_text_body(camp, aud, subsc, fall))
    |> Exmail.Mailer.deliver_later  # Exmail.Mailer.deliver_now camp_mail
  end
  # defp deliver_with_nested(%Bamboo.Email{} = email, %{type: "ABTest"} = camp, body) do
    # reltype = Campaign.reltype camp
  # end
  # defp deliver_with_nested(%Bamboo.Email{} = email, %{type: "RSS"} = camp, body) do
    # reltype = Campaign.reltype camp
  # end
  defp deliver_with_nested(%Bamboo.Email{} = email, %{type: "Text"} = camp, aud, subsc, {body, _}) do
    reltype = Campaign.reltype camp

    email
    |> nested_data(reltype)
    |> text_body(gen_text_body(camp, aud, subsc, body))
    |> Exmail.Mailer.deliver_later  # Exmail.Mailer.deliver_now camp_mail
  end

  # Resolve relational data perticular 1:N relation.
  #
  defp nested_data(%Bamboo.Email{} = email, reltype) when is_list(reltype) do
    Enum.map reltype, &nested_data(email, &1)
  end
  defp nested_data(%Bamboo.Email{} = email, reltype) do
    from_email = @additional[:from]
    # from_email = reltype.from_email

    email
    # TODO: Considers to add headres more.
    # |> put_header("Reply-To", from_email)
    # |> put_header("X-Original-Sender", from_email)
    |> from({reltype.from_name, from_email})
    |> subject(reltype.subject)
  end

  defp gen_header(%Bamboo.Email{} = email, camp, _aud, subsc, _body) do
    # rel  = Campaign.reltype camp
    eid  = Hash.mailify subsc.email
    cid  = Hash.mailify camp.id

    # uid  = Hash.mailify camp.user.id
    tid  = String.capitalize @mailer

    email
    |> put_header("Return-Path", @additional[:bounce])

    #
    |> put_header("X-Mailer", Hash.mailer_id(tid, [cid, eid]))
    |> put_header("X-Campaign", Hash.idify(@mailer, [eid, cid]))
    |> put_header("X-CampaignID", Hash.idify(@mailer, cid))

    # TODO: Considers to add headres more.
    # |> put_header("List-ID", "#{uid}#{@mailer} list <#{uid}.list-id.#{@mailinglist_receiver}>")
    # |> put_header("X-Report-Abuse", "Please report abuse for this campaign here: #{@http_receiver}/abuse/abuse.phtml?u=#{uid}&id=#{cid}&e=#{eid}")
    # |> put_header("X-#{tid}-User", uid)
    # |> put_header("List-Unsubscribe", "mailto:unsubscribe-#{@mailer}.#{uid}.#{cid}-#{eid}@#{@mail_receiver}?subject=unsubscribe," <>
                                      # "#{@http_receiver}/unsubscribe?u=#{uid}&e=#{eid}&c=#{cid}")

    # TODO: Support each signature here http://www.dkim.jp/dkim-jp/faq/ and https://github.com/awetzel/mailibex
    # |> put_header("DKIM-Signature", "")
  end

  defp gen_html_body(camp, aud, subsc, body) do
    eid = Hash.mailify subsc.email
    cid = Hash.mailify camp.id

    body
    |> ifput(camp.track_open, &Tracking.embed_open(&1, shorten_track_url(Endpoint, :open, cid, eid)))
    |> ifput(camp.track_html_click, &Tracking.embed_html_click(&1, shorten_track_url(Endpoint, :html_click, cid, eid)))
    |> gen_body(camp, aud, subsc)
  end

  defp gen_text_body(camp, aud, subsc, body) do
    eid = Hash.mailify subsc.email
    cid = Hash.mailify camp.id

    body
    |> ifput(camp.track_text_click, &Tracking.embed_text_click(&1, shorten_track_url(Endpoint, :text_click, cid, eid)))
    |> gen_body(camp, aud, subsc)
  end

  defp gen_body(body, camp, aud, subsc) do
    rel  = Campaign.reltype camp

    body
    |> Placeholder.email_address(subsc)
    |> Placeholder.first_name(subsc)
    |> Placeholder.last_name(subsc)
    |> Placeholder.audience_name(aud)
    |> Placeholder.audience_explain(aud)
    |> Placeholder.campaign_name(camp)
    |> Placeholder.campaign_subject(rel)
    |> Placeholder.campaign_from_name(rel)
    |> Placeholder.campaign_from_email(rel)
  end

  defp ifput(body, bool, fun) do
    if bool do
      fun.(body)
    else
      body
    end
  end


end
