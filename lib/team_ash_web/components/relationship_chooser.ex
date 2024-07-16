defmodule TeamAshWeb.RelationshipChooser do
  use TeamAshWeb, :live_component

  use LiveElements.CustomElementsHelpers

  custom_element(:simple_autocomplete, events: ["autocomplete-search"])

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(items: ["mom", "dad"])
     |> assign(assigns)}
  end

  def handle_event("autocomplete-search", %{"query" => query}, socket) do
    {:noreply, socket |> assign(items: ["mom", "dad", query])}
  end

  def handle_event("autocomplete-commit", params, socket) do
    IO.inspect(params, label: "You chose")
    {:noreply, socket |> assign(items: ["mom", "dad", "baby"])}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.label for={@id}><%= @label %></.label>
      <simple-autocomplete
        debounce="700"
        name="barry"
        phx-target={@myself}
        id={@id}
        list="other_chooser_list"
        clear-on-select="true"
        phx-hook="PhoenixCustomEventHook"
        phx-update="ignore"
        phx-send-events="autocomplete-search"
      >
      </simple-autocomplete>
      <ul slot="list" id={"other_chooser_list"}>
        <%= for item <- @items do %>
          <li role="option" data-label={item} data-value={item}><%= item %></li>
        <% end %>
      </ul>
    </div>
    """
  end
end
