defmodule Plug.Parsers.ALEXA do
  @behaviour Plug.Parsers
  import Plug.Conn

  defmodule InvalidAlexaSignatureError do
    @moduledoc """
      This request will not be processed due to an invalid signature
    """

    defexception message: "invalid signature", plug_status: 403
  end

  def parse(conn, "application", "json", _headers, opts) do
    chain_uri = get_req_header(conn, "signaturecertchainurl") |> List.first
    signature = get_req_header(conn, "signature") |> List.first
    if !chain_uri || !signature  do
      {:next, conn}
    else
      conn
      |> read_body(opts)
      |> validate_signature(chain_uri, signature)
      |> decode()
    end
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp validate_signature({:more, _, conn}, _, _) do
    {:error, :too_large, conn}
  end

  defp validate_signature({:error, :timeout}, _, _) do
    raise Plug.TimeoutError
  end

  defp validate_signature({:error, _}, _, _) do
    raise Plug.BadRequestError
  end

  defp validate_signature({:ok, body, conn}, chain_uri, signature) do
    case Alexa.validate_signature(chain_uri, signature, body) do
      :ok ->
        {:ok, body, conn}
      {:error, _reason} ->
        raise Plug.Parsers.ALEXA.InvalidAlexaSignatureError
    end
  end

  defp decode({:error, :too_large, _conn} = return) do
    return
  end

  defp decode({:ok, "", conn}) do
    {:ok, %{}, conn}
  end

  defp decode({:ok, body, conn}) do
    case Poison.decode!(body, as: %Alexa.RequestBody{}) do
      terms when is_map(terms) ->
        {:ok, terms, conn}
      terms ->
        {:ok, %{"_json" => terms}, conn}
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end

end
