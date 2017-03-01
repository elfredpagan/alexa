defmodule Alexa.Controller do
  use Phoenix.Controller

  def index(conn, request_body) do
    conn
    |> handle_request(request_body)
  end

  def handle_request(conn, request_body) do
    skill = conn.assigns[:skill]
    {conn, response} =
    case request_body.request.type do
      "IntentRequest" ->
        name = request_body.request.intent.name
        skill.handle_intent(conn, name, request_body)
      "LaunchRequest" ->
        skill.handle_launch(conn, request_body)
      "SessionEndedRequest" ->
        skill.handle_session_end(conn, request_body)
    end
    conn
    |> json(response)
  end

end
