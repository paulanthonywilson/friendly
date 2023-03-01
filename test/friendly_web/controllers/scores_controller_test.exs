defmodule FriendlyWeb.ScoresControllerTest do
  use FriendlyWeb.ConnCase, async: true

  alias Friendly.Points.User
  alias Friendly.Queries.UsersQueryResult

  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    {:ok, conn: conn}
  end

  test "nil timestamp, no users qualifying", %{conn: conn} do
    expect(MockFriendlyQueries, :max_two_qualifying_users, fn ->
      %UsersQueryResult{
        previous_query_timestamp: nil,
        qualifying_users: []
      }
    end)

    conn = get(conn, "/")

    assert %{
             "previous_query_timestamp" => nil,
             "qualifying_users" => []
           } == json_response(conn, 200)
  end

  test "not nil timestap", %{conn: conn} do
    expect(MockFriendlyQueries, :max_two_qualifying_users, fn ->
      %UsersQueryResult{
        previous_query_timestamp: ~U[2023-01-11 12:13:14.618564Z],
        qualifying_users: []
      }
    end)

    conn = get(conn, "/")

    assert %{
             "previous_query_timestamp" => "2023-01-11T12:13:14.618564Z"
           } = json_response(conn, 200)
  end

  test "with users", %{conn: conn} do
    expect(MockFriendlyQueries, :max_two_qualifying_users, fn ->
      %UsersQueryResult{
        previous_query_timestamp: ~U[2023-01-11 12:13:14.618564Z],
        qualifying_users: [%User{id: 1, points: 11}, %User{id: 23, points: 55}]
      }
    end)

    conn = get(conn, "/")

    assert %{
             "qualifying_users" => [%{"id" => 1, "points" => 11}, %{"id" => 23, "points" => 55}]
           } = json_response(conn, 200)
  end
end
