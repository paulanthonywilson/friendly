defmodule Friendly.RandomFloor do
  @moduledoc """
  For generating a random number between 0 and 100 (inclusive) for use in selecting
  users with points above a particular value
  """

  @doc "See moodule doc"
  @spec random_floor :: non_neg_integer
  def random_floor do
    :rand.uniform(101) - 1
  end
end
