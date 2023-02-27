defmodule Friendly.Points.User do
  @moduledoc """
  Ecto Schema for User.

  A user has points (and timestamps). That is all it has.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field :points, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
  end
end
