defmodule Friendly.PointsManagerTest do
  use Friendly.DataCase, async: true
  import Ecto.Query
  alias Fixtures.UserFixtures
  alias Friendly.Points.User
  alias Friendly.{PointsManager, Repo}

  setup do
    {:ok, pid} = start_supervised(PointsManager)
    Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), pid)
    :ok
  end

  describe "querying up to two users with points above the floor value" do
    setup do
      for i <- 5..1 do
        UserFixtures.create_user!(i)
      end

      :ok
    end

    test "timestamp included in result" do
      assert %{previous_query_timestamp: nil} =
               PointsManager.up_to_two_users_with_points_over_floor()

      assert %{previous_query_timestamp: %DateTime{}} =
               PointsManager.up_to_two_users_with_points_over_floor()
    end

    test "floor is initialised" do
      assert %{qualifying_points_floor: initial_floor} = :sys.get_state(PointsManager)
      assert initial_floor in 0..100
    end

    test "filters by points above the floor" do
      change_qualifying_floor(3)
      assert %{qualifying_users: users} = PointsManager.up_to_two_users_with_points_over_floor()
      assert [4, 5] = users |> Enum.map(&Map.get(&1, :points)) |> Enum.sort()

      change_qualifying_floor(4)
      assert %{qualifying_users: users} = PointsManager.up_to_two_users_with_points_over_floor()
      assert [5] = users |> Enum.map(&Map.get(&1, :points)) |> Enum.sort()
    end
  end

  describe "refreshing user points" do
    test "refreshing is scheduled on initialisation" do
      # defaults to a minute - take advantage of this testing seam
      PointsManager.init(refresh_every: 1)
      assert_receive :refresh_points

      # default is a minute so should not trigger here
      PointsManager.init([])
      refute_receive :refresh_points
    end

    test "user points are updated on refresh" do
      for _ <- 1..3 do
        UserFixtures.create_user!(-1)
      end

      send(PointsManager, :refresh_points)
      wait_for_points_manager_mailbox_to_clear()
      assert 3 == Repo.one(from u in User, select: count(u), where: u.points >= 0)
    end

    test "next refresh is scheduled on refresh" do
      PointsManager.handle_info(:refresh_points, %PointsManager{refresh_every: 1})
      assert_receive :refresh_points

      PointsManager.handle_info(:refresh_points, %PointsManager{refresh_every: :timer.seconds(60)})

      refute_receive :refresh_points
    end

    test "qualifying floor is changed on refresh" do
      change_qualifying_floor(-1)
      send(PointsManager, :refresh_points)
      assert %{qualifying_points_floor: floor} = :sys.get_state(PointsManager)
      assert floor >= 0
    end
  end

  defp wait_for_points_manager_mailbox_to_clear do
    :sys.get_state(PointsManager)
  end

  defp change_qualifying_floor(new_floor) do
    :sys.replace_state(PointsManager, fn state ->
      %{state | qualifying_points_floor: new_floor}
    end)
  end
end
