defmodule Shortener.Mailer do
  @moduledoc """
  The mailer of the link shortener. It sends each login link.
  """

  use Swoosh.Mailer, otp_app: :shortener
end
