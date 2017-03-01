defmodule Alexa do
  use Application

  defmacro skill(path, controller, options) do
    path_atom = String.to_atom(path)
    quote bind_quoted: [options: options], unquote: true do
      pipeline unquote(path_atom) do
        plug :accepts, ["json"]
        plug Alexa.ValidateAppID, app_id: Keyword.get(options, :app_id)
        plug Alexa.ValidateTimestamp
        plug Alexa.AuthenticateUser, auth_handler: Keyword.get(options, :auth_handler)
        plug Alexa.SkillPlug, skill: unquote(controller)
      end

      scope unquote(path) do
        pipe_through [unquote(path_atom)]
        post "/", Alexa.Controller, :index
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
