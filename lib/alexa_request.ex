defmodule Alexa.Application do
  defstruct [:applicationId]
end

defmodule Alexa.System do
  defstruct [:application]

  defimpl Poison.Decoder, for: Alexa.System do
    def decode(data, options) do
      data
      |> Map.update!(:application, fn application ->
        Poison.Decode.decode(application, Keyword.merge(options, as: %Alexa.Application{}))
      end)
    end
  end
end

defmodule Alexa.User do
  defstruct [:userId, :accessToken]
end

defmodule Alexa.Session do
  defstruct [:new, :sessionId, :application, :attributes, :user]

  defimpl Poison.Decoder, for: Alexa.Session do
    def decode(data, options) do
      data
      |> Map.update!(:application, fn application ->
        Poison.Decode.decode(application, Keyword.merge(options, as: %Alexa.Application{}))
      end)
      |> Map.update!(:user, fn user ->
        Poison.Decode.decode(user, Keyword.merge(options, as: %Alexa.User{}))
      end)
    end
  end
end

defmodule Alexa.Device do
  defstruct [:supportedInterfaces]
end

defmodule Alexa.Context do
  defstruct [:System, :user, :device]

  defimpl Poison.Decoder, for: Alexa.Context do
    def decode(data, options) do
      data
      |> Map.update!(:System, fn system ->
        Poison.Decode.decode(system, Keyword.merge(options, as: %Alexa.System{}))
      end)
      |> Map.update!(:user, fn user ->
        Poison.Decode.decode(user, Keyword.merge(options, as: %Alexa.User{}))
      end)
      |> Map.update!(:device, fn device ->
        Poison.Decode.decode(device, Keyword.merge(options, as: %Alexa.Device{}))
      end)
    end
  end
end

defmodule Alexa.Error do
  defstruct [:type, :message]
end

defmodule Alexa.Slot do
  defstruct [:name, :value]
end

defmodule Alexa.Intent do
  defstruct [:name, :slots]

  defimpl Poison.Decoder, for: Alexa.Intent do
    def decode(data, options) do
      data
      |> Map.update!(:slots, fn slots ->
        Map.new(Map.keys(slots), fn key ->
          {key, Poison.Decode.decode(slots[key], Keyword.merge(options, as: %Alexa.Slot{}))}
        end)
      end)
    end
  end
end

defmodule Alexa.Request do
  defstruct [:type, :requestId, :timestamp, :locale, :intent, :reason, :error]

  defimpl Poison.Decoder, for: Alexa.Request do
    def decode(data, options) do
      data
      |> Map.update!(:intent, fn intent ->
        Poison.Decode.decode(intent, Keyword.merge(options, as: %Alexa.Intent{}))
      end)
      |> Map.update!(:error, fn error ->
        Poison.Decode.decode(error, Keyword.merge(options, as: %Alexa.Error{}))
      end)
    end
  end
end

defmodule Alexa.RequestBody do
  defstruct [:version, :session, :context, :request]

  defimpl Poison.Decoder, for: Alexa.RequestBody do
    def decode(data, options) do
      data
      |> Map.update!(:session, fn session ->
        Poison.Decode.decode(session, Keyword.merge(options, as: %Alexa.Session{}))
      end)
      |> Map.update!(:request, fn request ->
        Poison.Decode.decode(request, Keyword.merge(options, as: %Alexa.Request{}))
      end)
      |> Map.update!(:context, fn context ->
        Poison.Decode.decode(context, Keyword.merge(options, as: %Alexa.Context{}))
      end)
    end
  end
end
