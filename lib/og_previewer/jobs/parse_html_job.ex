defmodule OgPreviewer.Jobs.ParseHtmlJob do
  use Oban.Worker, queue: :events, max_attempts: 10
  # set max attempts to 10 to address https://github.com/edgurgel/httpoison/issues/328
  require Logger

  import HTTPoison
  import Floki

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"url" => url}}) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        html = Floki.parse_document!(body)

        [url] =
          html
          |> Floki.find("[property='og:image']")
          |> Floki.attribute("content")

        {:ok, url}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "Something went wrong"}
    end

    :ok
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
