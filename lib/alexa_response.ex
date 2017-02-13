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
