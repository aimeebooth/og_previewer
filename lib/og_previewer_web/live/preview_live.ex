defmodule OgPreviewerWeb.PreviewLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket = assign(socket, :processing, false)
    {:ok, socket}
  end

  def render(%{url: _url} = assigns) do
    ~H"""
    <img src={assigns.url} alt="image" />
    """
  end

  def render(%{processing: false, url: nil} = assigns) do
    ~H"""
    Please enter a url here
    <form phx-submit="process_url">
      <input type="text" name="url" />
      <button type="submit" value="Submit">Submit</button>
    </form>
    """

    # todo: center content
  end

  def render(%{processing: true, url: nil} = assigns) do
    ~H"""
    Please wait while your image is being processed
    """

    # todo: add loading gif
  end

  def handle_event("process_url", %{"url" => url}, socket) do
    OgPreviewer.Jobs.ParseHtmlJob.new(%{url: url}) |> Oban.insert()
    socket = assign(socket, :processing, true)
    {:noreply, socket}
  end
end
