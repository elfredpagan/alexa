defmodule Alexa.AuthenticateUser do
  import Plug.Conn

  def init(opts) do
    Keyword.get(opts, :auth_handler)
  end

  def call(conn, nil) do
    conn
  end

  def call(conn, handler) do
    case handler.authenticate_user(conn, conn.body_params.session.user.accessToken) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
      {:error, response} ->
        conn
        |> resp(200, Poison.encode(response))
        |> halt()
    end
  end

end
