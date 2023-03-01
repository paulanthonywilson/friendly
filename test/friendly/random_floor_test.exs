defmodule Friendly.RandomFloorTest do
  use ExUnit.Case, async: true
  alias Friendly.RandomFloor
  @max_attempts 100_000_000

  test "random floor is between 0 and 100, inclusive" do
    # Property like test

    memo =
      Enum.reduce_while(
        1..@max_attempts,
        %{zero_generated?: false, hundred_generated?: false, mid_val_generated?: false, count: 0},
        fn _, memo ->
          memo =
            case RandomFloor.random_floor() do
              0 ->
                %{memo | zero_generated?: true}

              100 ->
                %{memo | hundred_generated?: true}

              val ->
                assert val in 1..99
                %{memo | mid_val_generated?: true}
            end

          if memo.zero_generated? && memo.hundred_generated? && memo.mid_val_generated? do
            {:halt, memo}
          else
            {:cont, memo}
          end
        end
      )

    assert memo.hundred_generated?
    assert memo.zero_generated?
    assert memo.mid_val_generated?
  end
end
