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
    |> assign(Map.take(assigns, @assigns))
    |> assign(:query, assigns.resource)
    |> load_rows()
    |> then(&{:ok, &1})
  end

  defp load_rows(%{assigns: %{query: query, sort: sort}} = socket) do
    rows = query |> Ash.Query.sort(sort) |> Ash.read!()
    assign(socket, :rows, rows)
  end

  @impl true
  def handle_event(
        "sort",
        %{"column" => column, "direction" => direction} = _params,
        socket
      ) do
    column = String.to_existing_atom(column)
    direction = String.to_existing_atom(direction)
    sort = {column, direction}

    socket
    |> assign(sort: sort)
    |> load_rows()
    |> then(&{:noreply, &1})
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
