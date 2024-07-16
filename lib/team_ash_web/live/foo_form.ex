defmodule TeamAshWeb.FooForm do

  use TeamAshWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <form>
      <div><label>Mom</label> <input name="mom" /></div>
      <div>
        <label>Dad</label>
        <foo-input name="dad"></foo-input>
      </div>
    </form>
    """
  end
end
