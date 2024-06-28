defmodule TeamAshWeb.EngagementsLive.IndexTest do
  use TeamAshWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TeamAsh.Engagements
  alias TeamAsh.Accounts

  setup %{conn: conn} do
    user = Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: "test@user.com",
      password: "password",
      password_confirmation: "password"
    })
    |> Ash.create!()

    %{conn: conn |> login(user)}
  end

  test "sort by engagement name", %{conn: conn} do


    Engagements.create_engagement!(%{name: "Puffle"})
    Engagements.create_engagement!(%{name: "Bubble"})
    Engagements.create_engagement!(%{name: "Zazzle"})

    {:ok, view, html} = live(conn, ~p"/engagements")

    assert has_element?(view, ~s/table tr:first-child/, "Puffle")

    view
    |> element(~s/th button[phx-value-column="name"]/)
    |> render_click()

    assert has_element?(view, ~s/table tr:first-child/, "Bubble")
  end

  test "sort by client name", %{conn: conn} do
    client1 = Engagements.create_client!(%{name: "Poo"})
    client2 = Engagements.create_client!(%{name: "Yap"})
    client3 = Engagements.create_client!(%{name: "Bob"})

    Engagements.create_engagement!(%{client_id: client1.id, name: "Wut"})
    Engagements.create_engagement!(%{client_id: client2.id, name: "Wutter"})
    Engagements.create_engagement!(%{client_id: client3.id, name: "Wuttest"})

    {:ok, view, html} = live(conn, ~p"/engagements")

    view
    |> element(~s/th button[phx-value-column="client.name"]/)
    |> render_click()

    assert has_element?(view, ~s/table tr:first-child/, "Bob")
  end

  defp login(conn, user) do
    subject = AshAuthentication.user_to_subject(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session("user", subject)
  end
end
