defmodule FriendlyWeb.ScoresController do
  @moduledoc """
  Endpoint for scores. When running locally with `iex -S mix phx.server`, `curl http://localhost:4000`
  returns users with scores that are above the currently randomly assigned `min_number` (which is not exposed)
  """
  alias Friendly.Queries
  use FriendlyWeb, :controller
  use Friendly.Queries

  @spec qualifying_two_users(Plug.Conn.t(), any) :: Plug.Conn.t()
  def qualifying_two_users(conn, _params) do
    qualifying = Queries.max_two_qualifying_users()

    json(conn, to_map(qualifying))
  end

  defp to_map(%{
         previous_query_timestamp: previous_query_timestamp,
         qualifying_users: qualifying_users
       }) do
    %{
      previous_query_timestamp: previous_query_timestamp,
      qualifying_users: Enum.map(qualifying_users, &Map.take(&1, [:id, :points]))
    }
  end
end
