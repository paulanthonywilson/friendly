defmodule Friendly.Queries do
  @moduledoc """
  Behaviour for providing a testing steam between the web (api) layer and the domain layer.

  For convenience `use Friendly.Queries` will alias `Queries` as

  * `MockFriendlyQueries` if the `Mix.env()` is test (and Mix.target() is not `elixir_ls`)
  * `Friendly.Queries` otherwise

  This approach is a little controversial. The advantage is better compiler and dialyzer warnings if you accidentally do the wrong thing.

  (Note that if you have to set the `elixir_ls` target youself in the `elixir_ls` settings in VSCode etc...)
  """

  defmodule UsersQueryResult do
    @moduledoc false
    keys = [:previous_query_timestamp, :qualifying_users]
    @enforce_keys keys
    defstruct keys

    @type t :: %__MODULE__{
            previous_query_timestamp: nil | DateTime.t(),
            qualifying_users: list(Friendly.Points.User.t())
          }
  end

  defmacro __using__(_) do
    impl =
      if apply(Mix, :env, []) == :test and apply(Mix, :target, []) != :elixir_ls do
        MockFriendlyQueries
      else
        Friendly.RealQueries
      end

    quote do
      alias unquote(impl), as: Queries
    end
  end

  @doc """
  Two users with points greater than the (randomly decided) qualifying points floor. May return one or zero
  if there are not enough qualifying.

  As specified in the exercise this is implemented with a GenServer call to the
  same process that is responsible for updating all the users, each with a new random
  points score.

  The update operation takes just over 5 seconds on a M2 Macbook Pro. If this query
  coincides with an update it could take a few seconds to complete (depending on hardware /
  network to a remote db). The timeout is currently set at 30 seconds.
  """
  @callback max_two_qualifying_users :: UsersQueryResult.t()
end
