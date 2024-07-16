defmodule TeamAshWeb.EngagementLive.FormComponent do
  use TeamAshWeb, :live_component

  alias TeamAsh.Engagements
  alias TeamAsh.Engagements.Engagement
  alias TeamAsh.Engagements.Client

  use LiveElements.CustomElementsHelpers

  custom_element(:autocomplete_input, events: ["autocomplete-search", "autocomplete-commit"])

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage engagement records in your database.</:subtitle>
      </.header>

      <.simple_form for={@form} id="engagement-form" phx-target={@myself} phx-submit="save" phx-change="validate">
        <.input field={@form[:starts_on]} type="date" label="Starts on" />
        <.input field={@form[:ends_on]} type="date" label="Ends on" />
        <.input field={@form[:name]} type="text" label="Name" />
        <div phx-feedback-for="engagement[client_id]">
          <.label for="engagement_client_id">Client</.label>
          <.autocomplete_input
            id="engagement_client_id"
            name="engagement[client_id]"
            phx-target={@myself}
            search-value={@clients_autocomplete_query}
            state={@clients_autocomplete_mode}
            value={client_id(@selected_client)}
          >
            <%= display_client(@selected_client) %>
            <ul slot="list">
              <li :for={client <- @clients} role="option" data-value={client.id}><%= client.name %></li>
            </ul>
          </.autocomplete_input>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Engagement</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp display_client(%Client{name: name}), do: name

  defp display_client(_), do: "Choose client..."

  defp client_id(%Client{id: id}), do: id
  defp client_id(_), do: nil

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(clients: [])
     |> assign(clients_autocomplete_mode: "closed")
     |> maybe_assign_selected_client(assigns.engagement)
     |> assign(clients_autocomplete_query: "")
     |> assign_form()}
  end

  defp maybe_assign_selected_client(socket, nil), do: socket |> assign(:selected_client, nil)

  defp maybe_assign_selected_client(socket, %Engagement{client: client}) do
    socket |> assign(:selected_client, client)
  end

  @impl true
  def handle_event("autocomplete-search", %{"query" => query}, socket) do
    {:noreply,
     socket
     |> assign(clients: Engagements.query_clients!(query))
     |> assign(clients_autocomplete_query: query)
     |> assign(clients_autocomplete_mode: "open")}
  end

  @impl true
  def handle_event("autocomplete-commit", %{"value" => client_id}, socket) do
    {:noreply,
     socket
     |> assign(selected_client: Engagements.get_client!(client_id))
     |> assign(clients: [])
     |> assign(clients_autocomplete_mode: "selected")}
  end

  @impl true
  def handle_event("validate", %{"engagement" => engagement_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, engagement_params))}
  end

  def handle_event("save", %{"engagement" => engagement_params} = all_stuff, socket) do
    IO.inspect(all_stuff)

    case AshPhoenix.Form.submit(socket.assigns.form, params: engagement_params) do
      {:ok, engagement} ->
        notify_parent({:saved, engagement})

        socket =
          socket
          |> put_flash(:info, "Engagement #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{engagement: engagement}} = socket) do
    form =
      if engagement do
        AshPhoenix.Form.for_update(engagement, :update,
          as: "engagement",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(TeamAsh.Engagements.Engagement, :create,
          as: "engagement",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end

  def client_options() do
    Engagements.list_clients!() |> Enum.map(&{&1.name, &1.id})
  end
end
