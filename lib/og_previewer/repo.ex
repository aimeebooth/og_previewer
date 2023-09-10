defmodule OgPreviewer.Repo do
  use Ecto.Repo,
    otp_app: :og_previewer,
    adapter: Ecto.Adapters.Postgres
end
