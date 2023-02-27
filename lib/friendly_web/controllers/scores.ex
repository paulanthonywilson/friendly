defmodule FriendlyWeb.Scores do
  @moduledoc """
  Endpoint for scores. When running locally with `iex -S mix phx.server`, `curl http://localhost:4000`
  returns users with scores that are above the currently randomly assigned `min_number` (which is not exposed)
  """
  use FriendlyWeb, :controller

  @spec two_above_minimum(Plug.Conn.t(), any) :: Plug.Conn.t()
  def two_above_minimum(conn, _params) do
    json(conn, %{hello: :matey})
  end
end
