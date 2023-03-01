defmodule Friendly.Points.User do
  @moduledoc """
  Ecto Schema for User.

  A user has points (and timestamps). That is all it has.

  Users are not updated or inserted anywhere in this app with validation; no `changeset/2` function is
  provided
  """

  use Ecto.Schema

  @type t :: %__MODULE__{
          id: pos_integer(),
          points: non_neg_integer(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "users" do
    field :points, :integer

    timestamps()
  end
end
