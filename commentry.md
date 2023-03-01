# Commentry

## Assumptions

The "requirements" specify that the database should be seeded with 1,000,000 users. I have taken that million as the number of users to be supported.

The requirements state that every minute the `GenServer` "should update every user's points"; that implies that the minutely updates should happen at one time and be atomic and I have assumed as much.

The example JSON is given as "something like". I have assumed that means I have permission to change the JSON key values to be a bit more meaningful.

## Design considerations

## Naming

I have taken the naming in exercise "requirements" as a suggestion, as the wording implies. I have renamed the following

* `min_level` to `qualifying_points_floor`. _Min_ implies to me that values should be greater _or equal_ to this level but the specification states that returned users' points should be above this level. Things tend to be above a floor.
* `timestamp` to `previous_query_timestamp`, clarifies what it is a timestamp of.

### Big atomic update

Updating a million rows atomically is challenging. A niave approach(see below) takes over a minute (often much longer) on a MacBook Pro M2 which would mean failing to update every minute. The requirement to bottle next the query through the same GenServer would make the API very sluggish.

```elixir
    User
    |> Repo.all(timeout: :timer.minutes(10))
    |> Enum.reduce(Multi.new(), fn u, multi ->
      cs = User.changeset(u, %{points: :rand.uniform(101) - 1})
      Multi.update(multi, {:u, u.id}, cs)
    end)
    |> Repo.transaction(timeout: :timer.minutes(10))
```

A strategy I considered to optimise the update involved:

* Caching all `id`s in memory
* Assigning the next random score also in memory
* Batch updating (`Ecto.Multi.update_all/5`) per ids assigned to a new score

I do not know how fast that would be but I am sceptical that it would be very quick.

Instead I opted for the much simpler use of Postgresql's `random` function. See `Friendly.Points.randomly_update_all_points/1`, with a slight simplification.

```elixir
from(u in User, update: [set: [points: fragment("floor(random() * 101)")]])
|> Repo.update_all([])
```

That takes just over 5 seconds on my M2 MacBook Pro, which I deem currently acceptable. For a production application I would suggest instrumenting the update, and triggering a warning if the value starts to exceed (say) 10 seconds. We may want to look into whether the score updates need to be atomic, whether they need to be every minute.

Partitioning the users in some way and having a rolling update throughout a minute (or other time period) would ease the spot-load of the instantaneous update.


### GenServer usage

Using a GenServer in this way is suspiciously non-optimal, almost as if the exercise designers wanted this calling out. Even without using the same GenServer for updating the values, it means that only one client can use the API at a time. With the updates to every user occuring every minute, this means that (with a 5 second update time) 20% of the time there will be some delay to running the query.

With a small user base this might not be a problem but there is no real need for it. 

Querying the database should be done in same process as the web request.  The other state needed, the `previous_query timestamp` and the `qualifying_points_score` could be held in `ets` for maximum conccurrency. 

Using a GenServer to schedule the periodic updates is fine, though. For more robust solutions with multiple production instances, I would consider using something like _Oban Cron_.

## Testing considerations

### Random numbers

Time and randomness are both hard to deal with in automated tests. One approach is to encapsulate the non-deterministic part which is stubbed (or mocked) to make them deterministic. Using a `postgresql` function for randomness would make this approach challenging in one place. I have opted for a more brute force approach in two place; close (but not quite) to being property based.

### Named GenServer testing

I am always uncomfortable with some tradeoff when testing named GenServers. With `Friendly.PointsManger` I have

* Opted to remove from the supervision tree in the test environment, to discourage its use in other tests
* Used `start_supervised/1` to launch it in its `Friendly.PointsManagerTest` 
* Kept its production name in the global registry in its test. 

Other strategies are available.