defmodule Alexa.ValidateAppID do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :app_id)
  end

  def call(conn, app_id) do
    case conn.body_params.session.application.applicationId do
      ^app_id ->
        conn
      _ ->
        conn
        |> resp(401, "Invalid App ID")
        |> halt()
    end
  end
end
