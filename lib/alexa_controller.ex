defmodule Alexa.Controller do
  defmacro __using__(opts) do
    quote do
      @app_id unquote(opts[:app_id])

      def validate_signature(conn) do
        conn
      end

      def validate_app_id(conn, app_id) do
        case app_id do
          @app_id ->
            conn
          _ ->
            conn
            |> resp(401, "Invalid App ID")
            |> halt()
        end
      end

      def index(conn, params) do
        request_body = Poison.Decode.decode params, as: %Alexa.RequestBody{}
        access_token = request_body.session.user.accessToken
        conn = validate_app_id(conn, request_body.session.application.applicationId)
        |> validate_signature()
        unless conn.halted do
          conn
          |> handle_auth(request_body.session.user.accessToken)
          |> handle_request(request_body)
        else
          conn
        end
      end

      def handle_request(conn, request_body) do
        case request_body.request.type do
          "IntentRequest" ->
            name = request_body.request.intent.name
            slots = request_body.request.intent.slots
            conn
            |> handle_intent(request_body.session, name, slots)
          "LaunchRequest" ->
            conn
            |> handle_launch(request_body.session, request_body.request)
          "SessionEndRequest" ->
            conn
            |> handle_session_end(request_body.session, request_body.request)
        end
        |> complete_response()
      end

      def handle_auth(conn, access_token) do
        conn
      end

      def handle_intent(conn, session, name, slots) do
        conn
      end

      def handle_launch(conn, session, request) do
        conn
      end

      def handle_session_end(conn, session, request) do
        conn
      end

      def continue_session(conn) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Kernel.put_in(response.response.shouldEndSession, false)
        conn = assign(conn, :alexa_response, response)
      end

      def put_session_attribute(conn, key, value) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Map.put(response, :sessionAttributes, Map.put(response.sessionAttributes, key, value))
        conn
        |> assign(:alexa_response, response)
      end

      def say(conn, text) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Kernel.put_in(response.response.outputSpeech, %Alexa.OutputSpeech{text: text})
        conn
        |> assign(:alexa_response, response)
      end

      def say_ssml(conn, text) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Kernel.put_in(response.response.outputSpeech, %Alexa.OutputSpeech{type: "SSML", ssml: text})
        conn
        |> assign(:alexa_response, response)
      end

      def card(conn, type, title, content, text, image) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Kernel.put_in(response.response.card, %Alexa.Card{type: type, title: title, content: content, text: text, image: image})
        conn
        |> assign(:alexa_response, response)
      end

      def card(conn, card) do
        response = conn.assigns[:alexa_response] || %Alexa.ResponseBody{}
        response = Kernel.put_in(response.response.card, card)
        conn
        |> assign(:alexa_response, response)
      end

      def complete_response(conn) do
        json(conn, conn.assigns[:alexa_response])
      end

      defoverridable [handle_auth: 2, handle_intent: 4, handle_launch: 3, handle_session_end: 3]
    end
  end
end
