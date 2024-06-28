defmodule TeamAshWeb.EngagementLive.FormComponent do
  use TeamAshWeb, :live_component

  alias TeamAsh.Engagements

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage engagement records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="engagement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:starts_on]} type="date" label="Starts on" />
        <.input field={@form[:ends_on]} type="date" label="Ends on" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:client_id]} type="select" label="Client" options={client_options()} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Engagement</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"engagement" => engagement_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, engagement_params))}
  end

  def handle_event("save", %{"engagement" => engagement_params}, socket) do
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
    Engagements.list_clients!() |> Enum.map(& {&1.name, &1.id})
  end
end
