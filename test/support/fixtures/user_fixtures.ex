defmodule Fixtures.UserFixtures do
  @moduledoc """
  For creating users in tests

  """
  alias Friendly.Points.User
  alias Friendly.Repo

  def create_user!(points \\ 0) do
    Repo.insert!(%User{points: points})
  end
end
