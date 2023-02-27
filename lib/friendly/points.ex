defmodule Friendly.Points do
  @moduledoc """
  Context for dealing with users that have points.

  (As this is an exercise without any known really application, naming the context name is a conceit
  that the domain is all about points.)
  """
  alias Friendly.Points.User
  alias Friendly.Repo

  import Ecto.Query

  @doc """
  Returns at most `limit` users with points over the `floor` value.
  """
  def users_with_points_over(floor, limit \\ 2) do
    from(u in User, where: u.points > ^floor, limit: ^limit) |> Repo.all()
  end
end
