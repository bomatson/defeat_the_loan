defmodule DefeatTheLoan.PageController do
  use DefeatTheLoan.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
