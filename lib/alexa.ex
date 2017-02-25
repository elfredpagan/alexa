defmodule Alexa do
  use Application

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

  def start_link(_) do
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Starts a worker by calling: Apns.Worker.start_link(arg1, arg2, arg3)
      worker(Alexa.SignatureValidator, [:ok]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: APNS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def validate_signature(chain_uri, signature, body) do
    Alexa.SignatureValidator.validate_signature(chain_uri, signature, body)
  end

end
