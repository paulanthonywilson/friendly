defmodule Friendly.PointsTest do
  use Friendly.DataCase

  alias Friendly.{Points, Points.User}

  test "Users can be created with 0 (zero) points, and can be listed" do
    assert {:ok, %User{id: id, points: 0}} = Points.create_user()
    assert [%User{id: ^id, points: 0}] = Points.list_users()
  end
end
