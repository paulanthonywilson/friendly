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
  @spec users_with_points_over(floor :: integer(), limit :: pos_integer()) :: any
  def users_with_points_over(floor, limit \\ 2) do
    from(u in User, where: u.points > ^floor, limit: ^limit) |> Repo.all()
  end

  @doc """
  Randomly updates every user in the database with a random number between 0 and `max_value` (inclusive). Uses
  the Postgresql random function which *is not cryptographically secure*.

  An `ok` tuple is returned, the second element being the number of updates (ie the number of users).
  """
  @spec randomly_update_all_points(max_value :: pos_integer()) ::
          {:ok, user_count :: non_neg_integer()}
  def randomly_update_all_points(max_value \\ 100) do
    ceiling = max_value + 1

    {count, nil} =
      from(u in User, update: [set: [points: fragment("floor(random() * ?)", ^ceiling)]])
      |> Repo.update_all([])

    {:ok, count}
  end
end
