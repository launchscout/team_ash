defmodule TeamAshWeb.ClientLive.Show do
  use TeamAshWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Client <%= @client.id %>
      <:subtitle>This is a client record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/clients/#{@client}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit client</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @client.id %></:item>
      <:item title="Name"><%= @client.name %></:item>
      <:item title="Owner"><%= @client.owner %></:item>
      <:item title="Source"><%= @client.source %></:item>
      <:item title="Closed On"><%= @client.closed_on %></:item>
    </.list>

    <.back navigate={~p"/clients"}>Back to clients</.back>

    <.modal
      :if={@live_action == :edit}
      id="client-modal"
      show
      on_cancel={JS.patch(~p"/clients/#{@client}")}
    >
      <.live_component
        module={TeamAshWeb.ClientLive.FormComponent}
        id={@client.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        client={@client}
        patch={~p"/clients/#{@client}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :client,
       Ash.get!(TeamAsh.Engagements.Client, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Client"
  defp page_title(:edit), do: "Edit Client"
end
