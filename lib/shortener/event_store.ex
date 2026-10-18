defmodule Shortener.EventStore do
  @moduledoc """
  The DCB event store of the link shortener, in SQLite.

  The table `events` holds each event in the order of its position. The
  table `event_tags` holds one row for each tag of each event. A query
  finds the events of a tag in `event_tags`, and a read gives the tags of
  each event from it.

  `append/2` checks the append condition and inserts the events in one
  transaction. The repository starts each transaction with
  `BEGIN IMMEDIATE`, so a second append waits until the first one ends.
  """

  @behaviour Shortener.DCB.EventStore

  import Ecto.Query

  alias Shortener.DCB.{AppendCondition, Event, Query, QueryItem, SequencedEvent}
  alias Shortener.Repo

  @impl true
  def read(%Query{} = query, opts) do
    after_position = Keyword.get(opts, :after)

    events =
      from(e in "events",
        where: ^matching(query),
        order_by: e.position,
        select: {e.position, e.type, e.data}
      )
      |> after_position(after_position)
      |> Repo.all()

    tags = tags_by_position(Enum.map(events, fn {position, _type, _data} -> position end))

    Enum.map(events, fn {position, type, data} ->
      %SequencedEvent{
        position: position,
        event: %Event{type: type, data: data, tags: Map.get(tags, position, [])}
      }
    end)
  end

  @impl true
  def append(events, condition) do
    events = List.wrap(events)

    Repo.transaction(fn ->
      if condition_fails?(condition), do: Repo.rollback(:append_condition_failed)
      Enum.each(events, &insert_event/1)
    end)
    |> case do
      {:ok, :ok} -> :ok
      {:error, :append_condition_failed} -> {:error, :append_condition_failed}
    end
  end

  defp condition_fails?(nil), do: false

  defp condition_fails?(%AppendCondition{fail_if_events_match: query, after: after_position}) do
    from(e in "events", where: ^matching(query))
    |> after_position(after_position)
    |> Repo.exists?()
  end

  defp insert_event(%Event{type: type, data: data, tags: tags}) do
    {1, [%{position: position}]} =
      Repo.insert_all("events", [%{type: type, data: data, appended_at: DateTime.utc_now()}],
        returning: [:position]
      )

    Repo.insert_all("event_tags", Enum.map(Enum.uniq(tags), &%{tag: &1, position: position}))
  end

  # The tags of each event, in the order of the tag. The tags of an event
  # are a set, so their order has no meaning.
  defp tags_by_position([]), do: %{}

  defp tags_by_position(positions) do
    from(t in "event_tags",
      where: t.position in ^positions,
      order_by: [t.position, t.tag],
      select: {t.position, t.tag}
    )
    |> Repo.all()
    |> Enum.group_by(fn {position, _tag} -> position end, fn {_position, tag} -> tag end)
  end

  defp after_position(queryable, nil), do: queryable
  defp after_position(queryable, position), do: where(queryable, [e], e.position > ^position)

  defp matching(%Query{all?: true}), do: dynamic(true)

  defp matching(%Query{items: items}),
    do:
      Enum.reduce(items, dynamic(false), fn item, acc -> dynamic(^acc or ^matching_item(item)) end)

  defp matching_item(%QueryItem{types: types, tags: tags}) do
    by_type = if types == [], do: dynamic(true), else: dynamic([e], e.type in ^types)

    case Enum.uniq(tags) do
      [] ->
        by_type

      tags ->
        tag_count = length(tags)

        positions =
          from(t in "event_tags",
            where: t.tag in ^tags,
            group_by: t.position,
            having: count(t.position) == ^tag_count,
            select: t.position
          )

        dynamic([e], ^by_type and e.position in subquery(positions))
    end
  end
end
