defmodule Alexa do
  defmacro alexa(path, controller) do
    quote do
      pipeline :alexa do
        plug :accepts, ["json"]
      end

      scope unquote(path), App do
        pipe_through :alexa

        post "/", unquote(controller), :index
      end
    end
  end
end
