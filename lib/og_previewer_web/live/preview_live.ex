defmodule OgPreviewerWeb.PreviewLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> assign(:url, nil)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(OgPreviewer.PubSub, "url:complete")
    end

    {:ok, socket}
  end

  def render(%{processing: false, url: nil} = assigns) do
    ~H"""
    Please enter a url here
    <form phx-submit="process_url">
      <input type="text" name="url" />
      <button type="submit" value="Submit">Submit</button>
    </form>
    """

    # todo: button to retry
    # todo: center content
  end

  def render(%{processing: false, url: _url} = assigns) do
    ~H"""
    <img src={assigns.url} alt="image" />
    """
  end

  def render(%{processing: true, url: nil} = assigns) do
    ~H"""
    Please wait while your image is being processed
    """

    # todo: add loading gif
  end

  def handle_event("process_url", %{"url" => url}, socket) do
    OgPreviewer.Jobs.ParseHtmlJob.new(%{channel: OgPreviewer.PubSub, url: url}) |> Oban.insert()
    socket = assign(socket, :processing, true)
    {:noreply, socket}
  end

  def handle_info({:complete, url}, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> assign(:url, url)

    {:noreply, socket}
  end

  def handle_info({:failed}, socket) do
    IO.puts("Image processing failed")
    {:noreply, socket}
  end
end
