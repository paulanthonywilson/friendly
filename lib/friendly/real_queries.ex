defmodule Friendly.RealQueries do
  @moduledoc """
  Implementation of disintermediation layer between the domain and web, to provide a testing seam for the web
  """
  @behaviour Friendly.Queries

  @impl Friendly.Queries
  defdelegate max_two_qualifying_users, to: Friendly.PointsManager
end
