defmodule Shortener.DCB.DeciderTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.{Decider, Event, Projection, Query, QueryItem}
  alias Shortener.EventStore

  defp counter(tag) do
    %Projection{
      initial_state: 0,
      handlers: %{"Counted" => fn count, _event -> count + 1 end},
      tags: [tag]
    }
  end

  defp counted(tag), do: %Event{type: "Counted", data: "{}", tags: [tag]}

  defp counted_events(tag), do: EventStore.read(%Query{items: [%QueryItem{tags: [tag]}]}, [])

  # A decide function that appends a matching event of a second client on
  # each of its first `interruptions` calls, after the read of the decision.
  defp interrupted_decide(tag, interruptions) do
    {:ok, calls} = Agent.start_link(fn -> 0 end)

    fn %{count: count} ->
      call = Agent.get_and_update(calls, &{&1, &1 + 1})
      if call < interruptions, do: :ok = EventStore.append(counted(tag), nil)
      send(self(), {:decided_on, count})
      {:ok, [counted(tag)]}
    end
  end

  describe "running a command" do
    test "appends the events of the decision given no event arrives after the read" do
      assert {:ok, [_event]} =
               Decider.run(EventStore, [count: counter("c:1")], fn _ ->
                 {:ok, [counted("c:1")]}
               end)

      assert [_one] = counted_events("c:1")
    end

    test "decides again on the new state given a matching event arrives after the read" do
      assert {:ok, [_event]} =
               Decider.run(EventStore, [count: counter("c:1")], interrupted_decide("c:1", 1))

      assert_received {:decided_on, 0}
      assert_received {:decided_on, 1}
      assert [_interruption, _decision] = counted_events("c:1")
    end

    test "returns the conflict given a matching event arrives after each of three reads" do
      assert {:error, :append_condition_failed} =
               Decider.run(EventStore, [count: counter("c:1")], interrupted_decide("c:1", 3))

      assert [_, _, _] = counted_events("c:1")
    end

    test "appends at once given the event after the read does not match the query" do
      assert {:ok, [_event]} =
               Decider.run(EventStore, [count: counter("c:1")], interrupted_decide("c:2", 1))

      assert_received {:decided_on, 0}
      refute_received {:decided_on, _}
    end

    test "returns the error of the decision and appends nothing given the decision fails" do
      assert {:error, :rejected} =
               Decider.run(EventStore, [count: counter("c:1")], fn _ -> {:error, :rejected} end)

      assert [] = counted_events("c:1")
    end
  end
end
