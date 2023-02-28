defmodule Friendly.RandomFloorTest do
  use ExUnit.Case
  alias Friendly.RandomFloor
  @max_attempts 100_000_000

  test "random floor is between 0 and 100, inclusive" do
    # Property like test

    acc =
      Enum.reduce_while(
        1..@max_attempts,
        %{zero_encountered?: false, hundred_encountered?: false},
        fn _, acc ->
          acc =
            case RandomFloor.random_floor() do
              0 ->
                %{acc | zero_encountered?: true}

              100 ->
                %{acc | hundred_encountered?: true}

              val ->
                assert val > 0
                assert val < 100
                acc
            end

          if acc.zero_encountered? && acc.hundred_encountered? do
            {:halt, acc}
          else
            {:cont, acc}
          end
        end
      )

    assert acc.hundred_encountered?
    assert acc.zero_encountered?
  end
end
