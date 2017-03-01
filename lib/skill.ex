defmodule Alexa.Skill do
  defmacro __using__(_opts) do
    quote do
      import Alexa.API
      @behaviour Alexa.Skill

      def handle_intent(conn, name, _request) do
        {conn, nil}
      end

      def handle_launch(conn, _request) do
        {conn, nil}
      end

      def handle_session_end(conn, _request) do
        {conn, nil}
      end
      defoverridable [handle_intent: 3, handle_launch: 2, handle_session_end: 2]
    end
  end

  @callback handle_intent(Plug.Conn.T, String.T, Alexa.RequestBody) :: {Plug.Conn.T, Alexa.ResponseBody}
  @callback handle_launch(Plug.Conn.T, Alexa.RequestBody) :: {Plug.Conn.T, Alexa.ResponseBody}
  @callback handle_session_end(Plug.Conn.T, Alexa.RequestBody) :: {Plug.Conn.T, Alexa.ResponseBody}

end
