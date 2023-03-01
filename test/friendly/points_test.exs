defmodule Friendly.PointsTest do
  use Friendly.DataCase, async: true

  import Ecto.Query
  alias Fixtures.UserFixtures
  alias Friendly.{Points, Points.User, Repo}

  describe "users with points over" do
    setup do
      UserFixtures.create_user!(1)

      for points <- 5..1, do: UserFixtures.create_user!(points)

      :ok
    end

    test "returns all with points over the floor" do
      assert matching = Points.users_with_points_over(0, 10)

      assert [1, 1, 2, 3, 4, 5] ==
               Enum.map(matching, fn %{points: points} -> points end) |> Enum.sort()
    end

    test "only returns those with points greater than the floor value" do
      assert matching = Points.users_with_points_over(3, 10)

      assert [4, 5] == Enum.map(matching, fn %{points: points} -> points end) |> Enum.sort()

      assert [%User{points: 5}] = Points.users_with_points_over(4, 10)
      assert [] = Points.users_with_points_over(5, 10)
    end

    test "limits the number of users returned to the limit" do
      assert [%User{}] = Points.users_with_points_over(0, 1)
    end

    test "limit defaults to 2" do
      assert [%User{}, %User{}] = Points.users_with_points_over(0)
    end
  end

  describe "randomly updating all the users" do
    setup do
      for _ <- 1..600, do: UserFixtures.create_user!()
      :ok
    end

    test "returns ok tuple with the number of users updated" do
      assert {:ok, 600} = Points.randomly_update_all_points()

      from(u in User, limit: 1) |> Repo.one() |> Repo.delete!()

      assert {:ok, 599} = Points.randomly_update_all_points()
    end

    test "updates to random numbers between 0 and the max values (inclusive)" do
      check_distinct_points([0, 1, 2], 2)
      check_distinct_points([0, 1], 1)
    end
  end

  # Even with 600 users, I think there is a 1 in 200 chance of
  # any score not being a 0, 1, or 2 which might make the update
  # test flaky if run often enough in a busy CI environment.
  # This makes it much less likely (1 in 20,000).
  defp check_distinct_points(expected, max_value, count \\ 100)

  defp check_distinct_points(expected, max_value, 0) do
    # Ok, one more shot
    {:ok, _} = Points.randomly_update_all_points(max_value)
    assert expected == all_distinct_points()
  end

  defp check_distinct_points(expected, max_value, count) do
    {:ok, _} = Points.randomly_update_all_points(max_value)

    unless expected == all_distinct_points() do
      check_distinct_points(expected, max_value, count - 1)
    end
  end

  defp all_distinct_points do
    Repo.all(from u in User, select: u.points, distinct: true, order_by: [asc: u.points])
  end
end
