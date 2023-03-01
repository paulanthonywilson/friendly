# Friendly - Coding Exercise

This project is a solution for a simple coding exercise. It's name, "Friendly", is a random choice but not designed to be an opinion on naming projects by codeword vs purpose.

Typically in an internal application I would link to background and desired business outcomes. I am not linking here out of coyness; this is a public repo, while the exercise is proprietary.

Briefly though: 
* There is a single API endpoint. 
* Calling that end point returns a JSON response with containing the timestamp of the previous call and a list of up to two users. The users are selected as having "points" above a particular randomly assigned value. That value, and every the users' points are updated once a minute to random values.
* If less than two users qualify, then less than two users are returned.
* That qualifying value, and the user's points are restricted to be in the range of 0 to 100 (inclusive)
* As a user's points must be above the qualifying value to be returned then no user with 0 points will ever be returned.
* When the qualifying value is occasionally randomly assigned to be 100, then no user can be returned.

It is set up for development. Actual deployment is out of scope.

I have provided some commentary on the design, and "exercise specification" in `./COMMENTARY.md`. 


# Getting started for running in development

First clone [this repo from Github](https://github.com/paulanthonywilson/friendly) and cd into the directory.

```sh
git clone git@github.com:paulanthonywilson/friendly.git
cd friendly
```


You will need installed Erlang, Elixir, and Postgresql to be installed.

Elixir and Erlang versions are set in `.tool-versions`. As you are probably using [`asdf`](https://asdf-vm.com) you may need to `asdf install` or edit the `tool-versions` file. If you do run
with different Elixir or Erlang version and get warnings or errors, then that's on you though 😜.


## Setup

Running `mix setup` will get dependencies, create and migrate the development database, and seed the development database with 1,000,000 (1 million) entries in the `users` table, each with zero points.

Inserting 1,000,000 users does take time: just over 30 seconds on my M2 Macbook Pro (8 cores). 

`mix setup` is idempotent in that if entries are found in the only table, `users` then seeding will abort. You can override this by seeding seperately with some arguments.

To seed an extra million userse use the `--force` argument.

```sh
mix run priv/repo/seeds.exs --force
```

To drop the existing million, and seed a different million use `--delete-users`

```sh
 mix run priv/repo/seeds.exs --delete-users
```

## Testing and Linting

Please do run the unit tests. 

```sh
mix test
```
As per out-of-the-box Phoenix generated applications, on the first test run the test database will be silently created and migrated. 

`Credo` should have no suggestions. Running with `--strict` will throw out a few things that I think are fine in their particular context.

```sh
mix credo
```

Dialyzer should show no errors or warnings.

```sh
mix dialyzer
```

# Docs

If you like, you can run `mix docs` and read this and other documentation at `doc/readme.html`

# Running

Run with `iex -S mix phx.server` (or `mix phx.server` if that's your thing). The server listens on `localhost` (127.0.0.1), port 4000. You can navigate to http://localhost:4000 in your browser to see the returned JSON. (Aesthetes may prefer to `curl localhost:4000 | jq`.) 

If you query for the first time **after freshly seeding**, and within one minute of startup your result json will be like

```json
{
  "previous_query_timestamp": null,
  "qualifying_users": []
}
```

As to qualify to be returned the user must have points **greater** than a random value that can not be less than zero, and all users have zero points then no users will qualify for the JSON. As there has been no previous query to the api since startup, then the "previous_query_timestamp" will be `null`.

Querying again, within that first minute will show the time of the last query. Shortly before the time of writing this resulted in

```json
{
  "previous_query_timestamp": "2023-03-01T12:44:15.911222Z",
  "qualifying_users": []
}
```

After one minute the JSON will probably (49 out of 50 chance) return two users and you will see something like

```json
{
  "previous_query_timestamp": "2023-03-01T12:44:31.636517Z",
  "qualifying_users": [
    {
      "id": 6035861,
      "points": 81
    },
    {
      "id": 6035878,
      "points": 97
    }
  ]
}
```

There is no API way to see or manipulate the random value used to determine which users qualify to be returned. If you like you can hack it from the repl though (which is a good reason to use `iex -S mix phx.server` rather than `mix phx.server`). Bear in  mind that you have a maximum of one minute to query after hacking that value before it is randomly updated.

```elixir
iex> :sys.replace_state(PointsManager,&%{&1 | qualifying_points_floor: 100})
```

```json
{
  "previous_query_timestamp": "2023-03-01T12:54:10.954240Z",
  "qualifying_users": []
}
```

No user can have points greater than 100, so none will be returned.

```elixir
iex(6)> :sys.replace_state(PointsManager,&%{&1 | qualifying_points_floor: 99})  
```

```json
{
  "previous_query_timestamp": "2023-03-01T13:01:22.467757Z",
  "qualifying_users": [
    {
      "id": 6028463,
      "points": 100
    },
    {
      "id": 6028774,
      "points": 100
    }
  ]
}
```

Only users with 100 points will be returned; with 1,000,000 users there are bound to be around 10,000 maximum scoring users to choose from.

(The contents of `.iex.exs` are responsible for the lack of namespacing in the `iex` examples above.)

## Running in production mode

You can run in production mode by sourcing `.prod_env` before `iex -S mix phx.server`. The only reason I can think of doing that it is to look at the boiler plate 404 error, if you (say) `curl http://localhost:4000/somewhere`, but the facility is there.