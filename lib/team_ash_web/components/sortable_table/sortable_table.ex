defmodule TeamAshWeb.UI.SortableTable do
  alias TeamAshWeb.UI

  @moduledoc """
    Generic sortable table component

    Expects the following parameters as assigns:

    * `id` - necessary, as this is a stateful LiveView component
    * `resource` - An Ash resource module
    * `sort` (optional) - a `t:sort/0` specifying the initial sort direction
    * `col` columns
      * attribute - the field this column displays, used to sort
      * sort_expr - optional expression for complex sorts
    * `caption` (optional)

    Columns specified using either atoms or {atom, String} tuples are assumed to be sortable.

    ## Examples:
        rows = [%{id: 1, foo: 1, bar: "bar"}, %{id: 2, foo: 2, bar: "baa"}]
        <.live_component module={TeamAshWeb.UI.SortableTable} id="1"
            resource={TeamAsh.Engagements.Engagement}
            sort={{:name, :asc}}>
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

  defp load_rows(%{assigns: %{query: query, sort: {field, direction}, col: columns}} = socket) do
    rows = query |> Ash.Query.sort({String.to_existing_atom(field), direction}) |> Ash.read!()
    assign(socket, :rows, rows)
  end

  @impl true
  def handle_event(
        "sort",
        %{"column" => column, "direction" => direction} = _params,
        socket
      ) do
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
