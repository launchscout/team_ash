defmodule TeamAshWeb.EngagementsLive.IndexTest do
  use TeamAshWeb.ConnCase

  import Phoenix.LiveViewTest

  alias TeamAsh.Engagements
  alias TeamAsh.Accounts

  test "sort by engagement name", %{conn: conn} do
    user = Accounts.User
    |> Ash.Changeset.for_create(:register_with_password, %{
      email: "test@user.com",
      password: "password",
      password_confirmation: "password"
    })
    |> Ash.create!()

    Engagements.create_engagement!(%{name: "Puffle"})
    Engagements.create_engagement!(%{name: "Bubble"})
    Engagements.create_engagement!(%{name: "Zazzle"})

    {:ok, view, html} =
      conn
      |> login(user)
      |> live(~p"/engagements")

    assert has_element?(view, ~s/table tr:first-child/, "Puffle")

    view
    |> element(~s/th button[phx-value-column="name"]/)
    |> render_click()

    assert has_element?(view, ~s/table tr:first-child/, "Bubble")
  end

  defp login(conn, user) do
    subject = AshAuthentication.user_to_subject(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session("user", subject)
  end
end
