# OG Previewer

An Elixir/Phoenix application with LiveView that allows users to test and preview an Open Graph image from any given URL.

## Setup

The following steps assume a prior installation and setup of Elixir. This project uses `elixir 1.14.2-otp-25` and `erlang 25.2`.

1. Clone the repo, e.g. `git clone git@github.com:aimeebooth/og_previewer.git`
2. Change directories - `cd og_previewer`
3. Setup a local database - `mix ecto.create`
4. Run the app locally - `mix phx.server` or `iex -S mix phx.server`

## Approach

OG Previewer is a LiveView application that sends a user-submitted URL to an async task and reports the result back to a LiveView via Phoenix.PubSub. The LiveView handles the url processing state and conditionally updates the client over the socket connection. The first iteration of this solution used Oban to create a background job for the processing and stored the state in the database. The choice for Oban was made largely due to [this issue with HTTPoison#get/1](https://github.com/edgurgel/httpoison/issues/328) because I wanted a way to automatically retry requests. However, when I added an async handler for PubSub broadcasting the result to the LiveView, I realized allowing the LiveView to handle the processing state was a better solution and removed Oban. The one trade-off with allowing LV to handle state is that it's so fast, the `processing` state is barely visible in the browser before it updates and displays the image :)

An example 200 request can be seen with [J. Robert Oppenheimer](https://en.wikipedia.org/wiki/J._Robert_Oppenheimer) on Wikipedia.
An example of 308 handling can be seen with [ConAir](https://www.imdb.com/title/tt0118880) on IMDB.

## Issues

Some Open Graph-compliant URLs [cause a crash](https://github.com/edgurgel/httpoison/issues/328). With more time, I would want to figure out why that's happening and handle that edge case.
