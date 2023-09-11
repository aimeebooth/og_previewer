defmodule OgPreviewer.Jobs.ParseHtmlJob do
  use Oban.Worker, queue: :events, max_attempts: 10
  # set max attempts to 10 to address https://github.com/edgurgel/httpoison/issues/328
  require Logger

  import HTTPoison
  import Floki

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"channel" => channel, "url" => url}}) do
    build_url(url)
    await_url(channel)

    :ok
  end

  defp build_url(url) do
    job_pid = self()

    Task.async(fn ->
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          html = Floki.parse_document!(body)

          [url] =
            html
            |> Floki.find("[property='og:image']")
            |> Floki.attribute("content")

          send(job_pid, {:complete, url})
          :ok

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}

        _ ->
          {:error, "Something went wrong"}
      end
    end)
  end

  defp await_url(channel) do
    receive do
      {:complete, url} ->
        Phoenix.PubSub.broadcast(channel, "url:complete", {:complete, url})

      _ ->
        "error"
    after
      30_000 ->
        Phoenix.PubSub.broadcast(channel, "url:failed", {:failed})
        raise RuntimeError, "no progress after 30s"
    end
  end
end

# [
#   {"meta",
#    [
#      {"property", "og:image"},
#      {"content",
#       "https://m.media-amazon.com/images/M/MV5BZDJjOTE0N2EtMmRlZS00NzU0LWE0ZWQtM2Q3MWMxNjcwZjBhXkEyXkFqcGdeQXVyNDk3NzU2MTQ@._V1_FMjpg_UX1000_.jpg"}
#    ], []}
# ]

# OgPreviewer.Jobs.ParseHtmlJob.perform(%Oban.Job{args: %{"url" => "https://www.imdb.com/title/tt0117500/"}})
