# Script for populating the database, specically the users table which is the only one that exist.
# You can run it as:
#
#     `mix run priv/repo/seeds.exs`
#
#  Will not run if there are entries already in the table unless one of the following arguments are used
#  `--delete-users` : will delete existing users
#  `--force`: will create the new users regardless of whether existing users already exist.
#

alias Friendly.Points.User
alias Friendly.Repo

Logger.put_process_level(self(), :info)

to_insert_count = 1_000_000

populate_users = fn ->
  IO.puts("Seeding #{to_insert_count} new users. This could take a little while ... ")

  {time, _} =
    :timer.tc(fn ->
      1..to_insert_count
      |> Task.async_stream(fn i ->
        if rem(i, 50_000) == 0, do: IO.puts("inserting ...")

        # disable any debug level logging in `dev`, which slows things down
        Logger.put_process_level(self(), :info)
        Repo.insert(%User{})
      end)
      |> Stream.run()
    end)

  IO.puts("\n\n#{to_insert_count} seeded in #{time / 1_000_000} seconds")
end

if "--delete-users" in System.argv() do
  {delete_count, _} = Repo.delete_all(User)
  IO.puts("\nDeleted #{delete_count} users.\n\n")
end

if "--force" not in System.argv() && Repo.exists?(User) do
  IO.puts("""

  **ABORTING SEEDING**

  The users table is already populated.

  To seed anyway use
     mix run priv/repo/seeds.exs --force

  To delete existing users before seeding use
     mix run priv/repo/seeds.exs --delete-users


  """)
else
  populate_users.()
end
