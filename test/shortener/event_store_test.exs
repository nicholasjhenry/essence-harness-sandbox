defmodule Shortener.EventStoreTest do
  use Shortener.DataCase, async: false

  alias Shortener.DCB.{AppendCondition, Event, Query, QueryItem}
  alias Shortener.EventStore

  defp event(type, tags), do: %Event{type: type, data: ~s({"type":"#{type}"}), tags: tags}

  defp types(sequenced_events), do: Enum.map(sequenced_events, & &1.event.type)

  defp query(items), do: %Query{items: items}

  setup do
    :ok =
      EventStore.append(
        [
          event("A", ["course:c1"]),
          event("B", ["course:c1", "student:s1"]),
          event("C", ["student:s1"]),
          event("A", ["course:c2"])
        ],
        nil
      )
  end

  describe "reading events" do
    test "gives the events of the types of the item given an item with types" do
      assert ["A", "C", "A"] = types(EventStore.read(query([%QueryItem{types: ["A", "C"]}]), []))
    end

    test "gives only the events with each tag of the item given an item with two tags" do
      assert ["B"] =
               types(EventStore.read(query([%QueryItem{tags: ["course:c1", "student:s1"]}]), []))
    end

    test "gives the events of a type with the tag given an item with a type and a tag" do
      assert ["A"] =
               types(EventStore.read(query([%QueryItem{types: ["A"], tags: ["course:c1"]}]), []))
    end

    test "gives the events that match any item given two items" do
      items = [%QueryItem{types: ["C"]}, %QueryItem{types: ["A"], tags: ["course:c2"]}]
      assert ["C", "A"] = types(EventStore.read(query(items), []))
    end

    test "gives each event in position order given the query of all events" do
      events = EventStore.read(Query.all(), [])

      assert ["A", "B", "C", "A"] = types(events)
      assert Enum.map(events, & &1.position) == Enum.sort(Enum.map(events, & &1.position))
    end

    test "gives no event given a query with no items" do
      assert [] = EventStore.read(query([]), [])
    end

    test "gives only the events after the position given the after option" do
      [_first, second | _rest] = EventStore.read(Query.all(), [])
      assert ["C", "A"] = types(EventStore.read(Query.all(), after: second.position))
    end

    test "gives no event given a tag in a different case" do
      assert [] = EventStore.read(query([%QueryItem{tags: ["COURSE:C1"]}]), [])
    end

    test "gives the event with its type, data, and tags" do
      [sequenced | _rest] = EventStore.read(query([%QueryItem{types: ["B"]}]), [])

      assert sequenced.event == event("B", ["course:c1", "student:s1"])
    end
  end

  describe "appending events" do
    setup do
      %{last_position: List.last(EventStore.read(Query.all(), [])).position}
    end

    test "fails given an event after the position matches the condition", %{last_position: last} do
      condition = %AppendCondition{
        fail_if_events_match: query([%QueryItem{types: ["A"]}]),
        after: last - 1
      }

      assert {:error, :append_condition_failed} = EventStore.append(event("D", []), condition)
      assert [] = EventStore.read(query([%QueryItem{types: ["D"]}]), [])
    end

    test "appends given each matching event is at or before the position", %{last_position: last} do
      condition = %AppendCondition{
        fail_if_events_match: query([%QueryItem{types: ["A"]}]),
        after: last
      }

      assert :ok = EventStore.append(event("D", []), condition)
      assert ["D"] = types(EventStore.read(query([%QueryItem{types: ["D"]}]), []))
    end

    test "appends given no event matches the condition" do
      condition = %AppendCondition{
        fail_if_events_match: query([%QueryItem{tags: ["course:c9"]}]),
        after: nil
      }

      assert :ok = EventStore.append(event("D", ["course:c9"]), condition)
    end

    test "fails given a condition with no position and a matching event" do
      condition = %AppendCondition{
        fail_if_events_match: query([%QueryItem{tags: ["student:s1"]}]),
        after: nil
      }

      assert {:error, :append_condition_failed} = EventStore.append(event("D", []), condition)
    end

    test "appends no event of the list given the condition fails" do
      condition = %AppendCondition{
        fail_if_events_match: query([%QueryItem{types: ["C"]}]),
        after: nil
      }

      assert {:error, :append_condition_failed} =
               EventStore.append([event("D", []), event("E", [])], condition)

      assert [] = EventStore.read(query([%QueryItem{types: ["D", "E"]}]), [])
    end

    test "appends each event of the list in order given no condition" do
      assert :ok = EventStore.append([event("D", ["x:1"]), event("E", ["x:1"])], nil)
      assert ["D", "E"] = types(EventStore.read(query([%QueryItem{tags: ["x:1"]}]), []))
    end
  end
end
