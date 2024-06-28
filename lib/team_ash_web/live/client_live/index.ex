defmodule TeamAshWeb.ClientLive.Index do
  use TeamAshWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Clients
      <:actions>
        <.link patch={~p"/clients/new"}>
          <.button>New Client</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="clients"
      rows={@streams.clients}
      row_click={fn {_id, client} -> JS.navigate(~p"/clients/#{client}") end}
    >
      <:col :let={{_id, client}} label="Id"><%= client.id %></:col>
      <:col :let={{_id, client}} label="Name"><%= client.name %></:col>
      <:col :let={{_id, client}} label="Source"><%= client.source %></:col>

      <:action :let={{_id, client}}>
        <div class="sr-only">
          <.link navigate={~p"/clients/#{client}"}>Show</.link>
        </div>

        <.link patch={~p"/clients/#{client}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, client}}>
        <.link
          phx-click={JS.push("delete", value: %{id: client.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="client-modal"
      show
      on_cancel={JS.patch(~p"/clients")}
    >
      <.live_component
        module={TeamAshWeb.ClientLive.FormComponent}
        id={(@client && @client.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        client={@client}
        patch={~p"/clients"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :clients,
       Ash.read!(TeamAsh.Engagements.Client, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Client")
    |> assign(
      :client,
      Ash.get!(TeamAsh.Engagements.Client, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Client")
    |> assign(:client, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clients")
    |> assign(:client, nil)
  end

  @impl true
  def handle_info({TeamAshWeb.ClientLive.FormComponent, {:saved, client}}, socket) do
    {:noreply, stream_insert(socket, :clients, client)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    client = Ash.get!(TeamAsh.Engagements.Client, id, actor: socket.assigns.current_user)
    Ash.destroy!(client, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :clients, client)}
  end
end
