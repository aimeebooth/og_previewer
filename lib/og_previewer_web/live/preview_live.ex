defmodule OgPreviewerWeb.PreviewLive do
  use Phoenix.LiveView

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:errors, nil)
      |> assign(:processing, false)
      |> assign(:url, nil)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(OgPreviewer.PubSub, "url:complete")
      Phoenix.PubSub.subscribe(OgPreviewer.PubSub, "url:error")
    end

    {:ok, socket}
  end

  @impl true
  def render(%{errors: nil, processing: false, url: nil} = assigns) do
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

  @impl true
  def render(%{errors: nil, processing: false, url: _url} = assigns) do
    ~H"""
    <p>Your image preview:</p>
    <img src={assigns.url} alt="image" />
    """
  end

  @impl true
  def render(%{errors: nil, processing: true, url: nil} = assigns) do
    ~H"""
    Please wait while your image is being processed
    """

    # todo: add loading gif
  end

  @impl true
  def render(%{errors: _errors} = assigns) do
    ~H"""
    <p><%= assigns.errors %></p>

    <p>Try Again:</p>
    <form phx-submit="process_url">
      <input type="text" name="url" />
      <button type="submit" value="Submit">Submit</button>
    </form>
    """
  end

  @impl true
  def handle_event("process_url", %{"url" => url}, socket) do
    OgPreviewer.Jobs.ParseHtml.new(%{channel: OgPreviewer.PubSub, url: url})
    socket = assign(socket, :processing, true)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:complete, url}, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> assign(:url, url)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:error, reason}, socket) do
    socket = assign(socket, :errors, reason)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
