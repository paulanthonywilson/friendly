defmodule Friendly.PointsManager do
  @moduledoc """
  GenServer to manage updating and retriving points, which was fairly rigidly specified in the
  exercise description.

  Every minute
  * The floor value that a user's points must be above to be included in the query results is updated randomly
  to be between 0 and 100 (inclusive)
  * All users points are updated to be a random value between 0 and 100 inclusive.


  The first randomisation of users does not take place until a minute after the GenServer is intialised; this is
  not specified in the
  """
  use GenServer

  alias Friendly.{Points, Queries.UsersQueryResult}

  import Friendly.RandomFloor, only: [random_floor: 0]

  @behaviour Friendly.Queries

  @name __MODULE__

  @refresh_every :timer.minutes(1)
  @call_timeout :timer.seconds(30)

  defstruct [:refresh_every, :qualifying_points_floor, previous_query_timestamp: nil]

  @type t :: %__MODULE__{
          previous_query_timestamp: nil | DateTime.t(),
          qualifying_points_floor: pos_integer(),
          refresh_every: pos_integer()
        }

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  @impl Friendly.Queries
  def max_two_qualifying_users do
    GenServer.call(@name, :users_with_points_over, @call_timeout)
  end

  @impl GenServer
  def init(opts) do
    refresh_every = Keyword.get(opts, :refresh_every, @refresh_every)
    state = %__MODULE__{qualifying_points_floor: random_floor(), refresh_every: refresh_every}
    schedule_next_refresh(state)
    {:ok, state}
  end

  @impl GenServer
  def handle_call(
        :users_with_points_over,
        _from,
        %{
          previous_query_timestamp: previous_query_timestamp,
          qualifying_points_floor: qualifying_points_floor
        } = state
      ) do
    qualifying_users = Points.users_with_points_over(qualifying_points_floor)

    result = %UsersQueryResult{
      previous_query_timestamp: previous_query_timestamp,
      qualifying_users: qualifying_users
    }

    {:reply, result, %{state | previous_query_timestamp: DateTime.utc_now()}}
  end

  @impl GenServer
  def handle_info(:refresh_points, state) do
    schedule_next_refresh(state)
    Points.randomly_update_all_points()
    {:noreply, %{state | qualifying_points_floor: random_floor()}}
  end

  defp schedule_next_refresh(%{refresh_every: refresh_every}) do
    Process.send_after(self(), :refresh_points, refresh_every)
  end
end
