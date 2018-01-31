defmodule Exmail.Emails.Placeholder do
  @moduledoc """
  Email Address         *|EMAIL|*
  First Name            *|FNAME|*
  Last Name             *|LNAME|*
  Audience Name	        *|AUDIENCE:NAME|*
  Audience Explain	    *|AUDIENCE:EXPLAIN|*
  Audience Phone	    *|AUDIENCE:PHONE|*
  Audience Address      *|AUDIENCE:ADDRESS|*
  Campaign Name	        *|CAMPAIGN:NAME|*
  Campaign subject      *|CAMPAIGN:SUBJECT|*
  Campaign from name    *|CAMPAIGN:FROM_NAME|*
  Campaign from email   *|CAMPAIGN:FROM_EMAIL|*
  """
  # alias Exmail.Campaign

  def email_address(body, subscriber) do
    r body, "*|EMAIL|*", subscriber.email
  end

  def first_name(body, subscriber) do
    r body, "*|FNAME|*", subscriber.first_name
  end

  def last_name(body, subscriber) do
    r body, "*|LNAME|*", subscriber.last_name
  end

  def audience_name(body, audience) do
    r body, "*|AUDIENCE:NAME|*", audience.name
  end

  def audience_explain(body, audience) do
    r body, "*|AUDIENCE:EXPLAIN|*", audience.explain
  end

  # def audience_phone(audience, body) do
  #   r body, "*|AUDIENCE:PHONE|*", audience.phone
  # end

  # def audience_address(audience, body) do
  #   r body, "*|AUDIENCE:ADDRESS|*", audience.address
  # end

  def campaign_name(body, campaign) do
    r body, "*|CAMPAIGN:NAME|*", campaign.name
  end

  def campaign_subject(body, reltype) do
    r body, "*|CAMPAIGN:SUBJECT|*", reltype.subject
  end

  def campaign_from_name(body, reltype) do
    r body, "*|CAMPAIGN:FROM_NAME|*", reltype.from_name
  end

  def campaign_from_email(body, reltype) do
    r body, "*|CAMPAIGN:FROM_EMAIL|*", reltype.from_email
  end

  defp r(text, _be, nil) do
    text
  end
  defp r(text, be, af) do
    String.replace text, be, af
  end

end
