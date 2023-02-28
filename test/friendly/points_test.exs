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
      for _ <- 1..1_000, do: UserFixtures.create_user!()
      :ok
    end

    test "returns ok tuple with the number of users updated" do
      assert {:ok, 1_000} = Points.randomly_update_all_points()

      from(u in User, limit: 1) |> Repo.one() |> Repo.delete!()

      assert {:ok, 999} = Points.randomly_update_all_points()
    end

    test "updates to random numbers between 0 and the max values (inclusive)" do
      {:ok, 1_000} = Points.randomly_update_all_points(2)
      assert [0, 1, 2] == all_distinct_points()

      {:ok, 1_000} = Points.randomly_update_all_points(1)
      assert [0, 1] == all_distinct_points()
    end
  end

  defp all_distinct_points do
    Repo.all(from u in User, select: u.points, distinct: true, order_by: [asc: u.points])
  end
end
