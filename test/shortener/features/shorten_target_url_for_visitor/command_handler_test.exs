defmodule Shortener.Features.ShortenTargetUrlForVisitor.CommandHandlerTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.{Query, QueryItem}
  alias Shortener.EventStore
  alias Shortener.Features.ShortenTargetUrlForVisitor.{Command, CommandHandler}
  alias Shortener.Shared.LinkShortened

  @now ~U[2026-10-17 12:00:00.000000Z]
  @url "https://example.com/a/long/path"

  defp command(target_url) do
    %Command{}
    |> Command.changeset(%{"target_url" => target_url})
    |> Ecto.Changeset.apply_action!(:insert)
  end

  defp link_events, do: EventStore.read(%Query{items: [%QueryItem{types: ["LinkShortened"]}]}, [])

  describe "shortening a target URL for a visitor" do
    test "makes a link with the first candidate and no owner given no link has a candidate" do
      assert {:ok,
              %LinkShortened{
                short_code: "aaaaaaa",
                target_url: @url,
                owner_email_address: nil,
                shortened_at: @now
              }} =
               CommandHandler.handle(command(@url), ["aaaaaaa", "bbbbbbb", "ccccccc"], @now)
    end

    test "makes a link with the second candidate given a link has the first candidate" do
      {:ok, _} = CommandHandler.handle(command(@url), ["aaaaaaa"], @now)

      assert {:ok, %LinkShortened{short_code: "bbbbbbb"}} =
               CommandHandler.handle(command(@url), ["aaaaaaa", "bbbbbbb"], @now)
    end

    test "returns short code taken and makes no link given a link has each candidate" do
      {:ok, _} = CommandHandler.handle(command(@url), ["aaaaaaa"], @now)
      {:ok, _} = CommandHandler.handle(command(@url), ["bbbbbbb"], @now)

      assert {:error, :short_code_taken} =
               CommandHandler.handle(command(@url), ["aaaaaaa", "bbbbbbb"], @now)

      assert [_, _] = link_events()
    end

    test "makes a second link for the same target URL given a different candidate" do
      {:ok, _} = CommandHandler.handle(command(@url), ["aaaaaaa"], @now)

      assert {:ok, %LinkShortened{short_code: "bbbbbbb", target_url: @url}} =
               CommandHandler.handle(command(@url), ["bbbbbbb"], @now)
    end

    test "treats short codes that differ in case as two short codes" do
      {:ok, _} = CommandHandler.handle(command(@url), ["aaaaaaa"], @now)

      assert {:ok, %LinkShortened{short_code: "AAAAAAA"}} =
               CommandHandler.handle(command(@url), ["AAAAAAA"], @now)
    end

    test "returns short code taken and makes no link given a link has the one chosen candidate" do
      {:ok, _} = CommandHandler.handle(command(@url), ["Summer1"], @now)

      assert {:error, :short_code_taken} =
               CommandHandler.handle(command(@url), ["Summer1"], @now)

      assert [_] = link_events()
    end

    test "tags the event with the short code only" do
      {:ok, _} = CommandHandler.handle(command(@url), ["aaaaaaa"], @now)

      assert [%{event: %{tags: ["short_code:aaaaaaa"]}}] = link_events()
    end
  end

  describe "validating the command" do
    test "is valid given an https URL with a host" do
      assert Command.changeset(%Command{}, %{"target_url" => " https://example.com "}).valid?
    end

    test "is not valid given a URL with no scheme" do
      changeset = Command.changeset(%Command{}, %{"target_url" => "example.com/path"})
      assert %{target_url: ["must be an http or https URL with a host"]} = errors_on(changeset)
    end

    test "is not valid given an ftp URL" do
      changeset = Command.changeset(%Command{}, %{"target_url" => "ftp://example.com/file"})
      assert %{target_url: ["must be an http or https URL with a host"]} = errors_on(changeset)
    end

    test "is not valid given a javascript URL or a data URL" do
      for url <- ["javascript:alert(1)", "data:text/html,<script>alert(1)</script>"] do
        changeset = Command.changeset(%Command{}, %{"target_url" => url})
        assert %{target_url: ["must be an http or https URL with a host"]} = errors_on(changeset)
      end
    end

    test "is not valid given a URL with no host" do
      changeset = Command.changeset(%Command{}, %{"target_url" => "https:///path"})
      assert %{target_url: ["must be an http or https URL with a host"]} = errors_on(changeset)
    end

    test "is valid with the chosen short code given a short code of seven letters or digits" do
      changeset =
        Command.changeset(%Command{}, %{"target_url" => @url, "short_code" => " Summer1 "})

      assert {:ok, %Command{short_code: "Summer1"}} =
               Ecto.Changeset.apply_action(changeset, :insert)
    end

    test "is valid with no short code given an empty short code" do
      changeset = Command.changeset(%Command{}, %{"target_url" => @url, "short_code" => ""})

      assert {:ok, %Command{short_code: nil}} = Ecto.Changeset.apply_action(changeset, :insert)
    end

    test "is not valid given a short code that is not seven letters or digits" do
      changeset = Command.changeset(%Command{}, %{"target_url" => @url, "short_code" => "abc"})

      assert %{short_code: ["must be seven characters from A–Z, a–z, and 0–9"]} =
               errors_on(changeset)
    end

    test "is not valid given no URL" do
      changeset = Command.changeset(%Command{}, %{"target_url" => ""})
      assert %{target_url: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
