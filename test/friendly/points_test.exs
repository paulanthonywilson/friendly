defmodule Friendly.PointsTest do
  use Friendly.DataCase

  alias Fixtures.UserFixtures
  alias Friendly.{Points, Points.User}

  describe "users with points over" do
    setup do
      UserFixtures.create_user!(1)

      for points <- 5..1 do
        UserFixtures.create_user!(points)
      end

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
end
