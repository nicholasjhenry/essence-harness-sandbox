defmodule Shortener.Features.SendLoginLinkToUser.LoginEmail do
  @moduledoc """
  The email that carries a login link to the email address of its user.
  """

  import Swoosh.Email

  @spec new(String.t(), String.t()) :: Swoosh.Email.t()
  def new(email_address, login_link) do
    new()
    |> to(email_address)
    |> from({"Shortener", "login@shortener.localhost"})
    |> subject("Your login link")
    |> text_body("""
    Open this link to log in to the link shortener:

    #{login_link}

    The link is valid for 15 minutes, and for one login.
    If you did not ask for it, ignore this email.
    """)
  end
end
