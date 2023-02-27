defmodule Friendly.Points do
  @moduledoc """
  Context for dealing with users that have points.

  (As this is an exercise without any known really application, naming the context name is a conceit
  that the domain is all about points.)
  """
  alias Ecto.Changeset
  alias Friendly.Points.User
  alias Friendly.Repo

  @doc """
  Creates a user, with 0 (zero) points
  """
  @spec create_user :: {:ok, User.t()} | {:error, Changeset.t()}
  def create_user do
    %User{points: 0}
    |> Repo.insert()
  end

  @doc """
  List _all_ users (could be a lot)
  """
  @spec list_users :: list(User.t())
  def list_users do
    Repo.all(User)
  end
end
