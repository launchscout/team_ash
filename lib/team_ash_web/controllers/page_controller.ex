defmodule TeamAshWeb.PageController do
  use TeamAshWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def test_form(conn, _params), do: render(conn, :test_form)
end
