defmodule TeamAshWeb.ClientLive.FormComponent do
  use TeamAshWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage client records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="client-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" /><.input
          field={@form[:source]}
          type="text"
          label="Source"
        /><.input field={@form[:owner]} type="text" label="Owner" /><.input
          field={@form[:closed_on]}
          type="date"
          label="Closed on"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Client</.button>
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
  def handle_event("validate", %{"client" => client_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, client_params))}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: client_params) do
      {:ok, client} ->
        notify_parent({:saved, client})

        socket =
          socket
          |> put_flash(:info, "Client #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{client: client}} = socket) do
    form =
      if client do
        AshPhoenix.Form.for_update(client, :update,
          as: "client",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(TeamAsh.Engagements.Client, :create,
          as: "client",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
