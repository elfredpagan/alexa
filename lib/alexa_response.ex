defmodule Alexa.OutputSpeech do
  @derive [Poison.Encoder]
  defstruct [type: "PlainText", text: nil, ssml: nil]
end

defmodule Alexa.Image do
  @derive [Poison.Encoder]
  defstruct [:smallImageUrl, :largeImageUrl]
end

defmodule Alexa.Card do
  @derive [Poison.Encoder]
  defstruct [:type, :title, :content, :text, :image]
end

defmodule Alexa.Response do
  @derive [Poison.Encoder]
  defstruct [outputSpeech: nil, card: nil, reprompt: nil, shouldEndSession: true]
end

defmodule Alexa.Reprompt do
  @derive [Poison.Encoder]
  defstruct [outputSpeech: %Alexa.OutputSpeech{}]
end

defmodule Alexa.ResponseBody do
  @derive [Poison.Encoder]
  defstruct [version: "1.0", sessionAttributes: %{}, response: %Alexa.Response{}]
end

defmodule Alexa.API do
  def continue_session(response \\ %Alexa.ResponseBody{}) do
    Kernel.put_in(response.response.shouldEndSession, false)
  end

  def put_session_attribute(response \\ %Alexa.ResponseBody{}, key, value) do
    Map.put(response, :sessionAttributes, Map.put(response.sessionAttributes, key, value))
  end

  def say(response \\ %Alexa.ResponseBody{}, text) do
    Kernel.put_in(response.response.outputSpeech, %Alexa.OutputSpeech{text: text})
  end

  def say_ssml(response \\ %Alexa.ResponseBody{}, text) do
    Kernel.put_in(response.response.outputSpeech, %Alexa.OutputSpeech{type: "SSML", ssml: text})
  end

  def card(response \\ %Alexa.ResponseBody{}, type, title, content, text, image) do
    Kernel.put_in(response.response.card, %Alexa.Card{type: type, title: title, content: content, text: text, image: image})
  end

  def card(response \\ %Alexa.ResponseBody{}, card) do
    Kernel.put_in(response.response.card, card)
  end
end
