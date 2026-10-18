defmodule Shortener.Features.SendLoginLinkToUser.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.Query
  alias Shortener.Features.SendLoginLinkToUser.{Command, CommandHandler}
  alias Shortener.Shared.{EmailAddress, LoginLinkSent, Secret}

  @now ~U[2026-10-17 12:00:00.000000Z]

  test "records the hash of the login token, and not the login token" do
    command =
      %Command{}
      |> Command.changeset(%{"email_address" => " Ada@Example.com"})
      |> Ecto.Changeset.apply_action!(:insert)

    token = Secret.generate()

    assert {:ok, %LoginLinkSent{email_address: "ada@example.com", sent_at: @now}} =
             CommandHandler.handle(command, token, @now)

    [%{event: event}] = Shortener.EventStore.read(Query.all(), [])
    refute event.data =~ token
    assert event.data =~ Secret.hash(token)

    assert Enum.sort(event.tags) ==
             Enum.sort([
               "login_token:" <> Secret.hash(token),
               EmailAddress.tag("ada@example.com")
             ])
  end

  test "is not valid given an email address with no domain" do
    changeset = Command.changeset(%Command{}, %{"email_address" => "ada"})
    assert %{email_address: ["must have the form name@domain"]} = errors_on(changeset)
  end
end
