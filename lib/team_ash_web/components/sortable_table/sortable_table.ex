defmodule TeamAshWeb.UI.SortableTable do
  alias TeamAshWeb.UI

  @moduledoc """
    Generic sortable table component

    Expects the following parameters as assigns:

    * `id` - necessary, as this is a stateful LiveView component
    * `rows` - a list of maps to be displayed in the table body. Maps are expected to have `id` keys at a minimum, if a sort key is passed, that column heading becomes sortable by that key.
    * `sort` (optional) - a `t:sort/0` specifying the initial sort direction
    * `col` columns
    * `caption` (optional)
    * `filter_keys` (optional) - set of string-valued keys to search within using a default, basic case-insensitive string match. Overridden by filter_fn.
    * `filter_fn` (optional) - 2-arg predicate function taking item and search input, returning true if match

    Columns specified using either atoms or {atom, String} tuples are assumed to be sortable.

    ## Examples:
        rows = [%{id: 1, foo: 1, bar: "bar"}, %{id: 2, foo: 2, bar: "baa"}]
        <.live_component module={TeamAshWeb.UI.SortableTable} id="1"
            rows=rows
            sort={{:bar, :asc}}>
        </.live_component>

  """

  use TeamAshWeb, :live_component

  @assigns [
    :id,
    :rows,
    :sort,
    :resource,
    :stream_key,
    :caption,
    :filter_fn,
    :col,
    :pagination_target,
    :placeholder,
    :"phx-debounce"
  ]

  @type sort :: {atom | nil, :asc | :desc}

  @impl true
  def mount(socket) do
    socket
    |> assign(
      filter: nil,
      sort: {nil, :asc}
    )
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> stream(
      assigns.stream_key,
      read_rows(assigns.resource, assigns.sort)
    )
    |> assign(Map.take(assigns, @assigns))
    |> assign_new(:filter_fn, fn -> filter_on_keys(assigns[:filter_keys]) end)
    |> then(&{:ok, &1})
  end

  defp read_rows(resource, sort) do
    resource |> Ash.Query.sort(sort) |> Ash.read!()
  end

  def filter_on_keys(nil), do: nil

  def filter_on_keys(keys) do
    fn
      item, %{"search_string" => filter} when is_map(item) and is_binary(filter) ->
        filter = String.downcase(filter)

        keys
        |> Enum.map(&get_filter_value(item, &1))
        |> Enum.filter(&is_binary/1)
        |> Enum.map(&String.downcase/1)
        |> Enum.any?(&String.contains?(&1, filter))

      _, _ ->
        false
    end
  end

  defp get_filter_value(item, {key, nested}), do: get_filter_value(item[key], nested)
  defp get_filter_value(item, key), do: item[key] || ""

  @impl true
  def handle_event(
        "sort",
        %{"column" => column, "direction" => direction} = _params,
        %{assigns: %{resource: resource, stream_key: stream_key}} = socket
      ) do
    column = String.to_existing_atom(column)
    direction = String.to_existing_atom(direction)
    sort = {column, direction}

    socket
    |> assign(sort: sort)
    |> stream(
      stream_key,
      read_rows(resource, sort)
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("filter", %{"search" => filter}, socket) do
    socket
    |> assign(:filter, filter)
    |> noreply()
  end

  defp filter_rows(_filter_fn, filter, rows) when filter in ["", nil], do: rows

  defp filter_rows(filter_fn, filter, rows) do
    Enum.filter(rows, &filter_fn.(&1, filter))
  end

  def sort_class(column_key, {sort_key, direction}) do
    if String.to_existing_atom(column_key) == sort_key do
      Atom.to_string(direction)
    else
      "none"
    end
  end

  def sort_direction(column_key, sort) when is_binary(column_key) do
    column_key
    |> String.to_existing_atom()
    |> sort_direction(sort)
  end

  def sort_direction(column_key, {column_key, direction}), do: toggle_direction(direction)
  def sort_direction(_, _), do: :asc

  def toggle_direction(:asc), do: :desc
  def toggle_direction(:desc), do: :asc

  def sort_normalized_keys(keys) do
    fn obj ->
      keys |> Enum.map(&(obj[&1] || "")) |> Enum.map(&String.downcase/1) |> List.to_tuple()
    end
  end

  def noreply(term) do
    {:noreply, term}
  end

  def ok(term) do
    {:ok, term}
  end
end
