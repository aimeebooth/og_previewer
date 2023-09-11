defmodule OgPreviewer.Jobs.ParseHtml do
  require Logger

  def new(%{channel: channel, url: url}) do
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

          url =
            html
            |> Floki.find("[property='og:image']")
            |> Floki.attribute("content")
            |> Enum.at(0)

          send(job_pid, {:complete, url})
          {:ok, url}

        {:ok, %HTTPoison.Response{status_code: 308, body: _body}} ->
          reason = "This url has been permanently redirected"
          send(job_pid, {:error, reason})
          {:error, reason}

        {:error, %HTTPoison.Error{reason: reason}} ->
          send(job_pid, {:error, reason})
          {:error, reason}
      end
    end)
  end

  defp await_url(channel) do
    receive do
      {:complete, url} ->
        Phoenix.PubSub.broadcast(channel, "url:complete", {:complete, url})

      {:error, reason} ->
        Phoenix.PubSub.broadcast(channel, "url:error", {:error, reason})
    after
      30_000 ->
        Phoenix.PubSub.broadcast(channel, "url:error", {:error, "timeout"})
        raise RuntimeError, "no progress after 30s"
    end
  end
end
