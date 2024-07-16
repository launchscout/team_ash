defmodule TeamAshWeb.EngagementLive.Index do
  alias TeamAsh.Engagements
  use TeamAshWeb, :live_view

  alias TeamAshWeb.UI

  require Ash.Sort

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Engagements
      <:actions>
        <.link patch={~p"/engagements/new"}>
          <.button>New Engagement</.button>
        </.link>
      </:actions>
    </.header>

    <.live_component
      module={TeamAshWeb.UI.SortableTable}
      resource={Engagements.Engagement}
      sort={{"id", :asc}}
      id="engagements"
      row_click={fn engagement -> JS.navigate(~p"/engagements/#{engagement}") end}
    >
      <:col :let={engagement} label="Id" sort_key="id"><%= engagement.id %></:col>
      <:col :let={engagement} label="Name" sort_key="name">
        <.link navigate={~p"/engagements/#{engagement.id}"}><%= engagement.name %></.link>
      </:col>
      <:col :let={engagement} label="Client" sort_key="client.name" sort_fn={&sort_by_client_name/2}>
        <%= if engagement.client, do: engagement.client.name %>
      </:col>

      <:action :let={engagement}>
        <div class="sr-only">
          <.link navigate={~p"/engagements/#{engagement}"}>Show</.link>
        </div>

        <.link patch={~p"/engagements/#{engagement}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, engagement}}>
        <.link
          phx-click={JS.push("delete", value: %{id: engagement.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.live_component>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="engagement-modal"
      show
      on_cancel={JS.patch(~p"/engagements")}
    >
      <.live_component
        module={TeamAshWeb.EngagementLive.FormComponent}
        id={(@engagement && @engagement.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        engagement={@engagement}
        patch={~p"/engagements"}
      />
    </.modal>
    """
  end

  defp sort_by_client_name(query, direction) do
    Ash.Query.sort(query, {Ash.Sort.expr_sort(client.name), direction})
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :engagements,
       Ash.read!(TeamAsh.Engagements.Engagement, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Engagement")
    |> assign(
      :engagement,
      Ash.get!(TeamAsh.Engagements.Engagement, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Engagement")
    |> assign(:engagement, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Engagements")
    |> assign(:engagement, nil)
  end

  @impl true
  def handle_info({TeamAshWeb.EngagementLive.FormComponent, {:saved, engagement}}, socket) do
    {:noreply, stream_insert(socket, :engagements, engagement)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    engagement = Ash.get!(TeamAsh.Engagements.Engagement, id, actor: socket.assigns.current_user)
    Ash.destroy!(engagement, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :engagements, engagement)}
  end
end
