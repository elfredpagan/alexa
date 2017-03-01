defmodule Alexa.ValidateTimestamp do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _) do
    timestamp = conn.body_params.request.timestamp
    {:ok, date} =  Timex.parse(timestamp, "{ISO:Extended}")
    date = date
    now = Timex.now

    if Timex.diff(date, now, :minutes) > 10 do
      resp(conn, 401, "expired request")
      |> halt()
    else
      conn
    end
  end
end
