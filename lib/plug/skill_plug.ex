defmodule Alexa.SkillPlug do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :skill)
  end

  def call(conn, skill) do
    assign(conn, :skill, skill)
  end

end
