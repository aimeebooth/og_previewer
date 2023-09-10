defmodule OgPreviewerWeb.ErrorJSONTest do
  use OgPreviewerWeb.ConnCase, async: true

  test "renders 404" do
    assert OgPreviewerWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert OgPreviewerWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
