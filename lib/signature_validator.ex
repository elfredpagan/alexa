defmodule Alexa.SignatureValidator do
  require Alexa.Records
  use GenServer

  def start_link(_) do
    state = %{}
    GenServer.start_link(__MODULE__, state, name: Alexa.SignatureValidator)
  end

  def validate_signature(chain_uri, signature, body) do
    GenServer.call(Alexa.SignatureValidator, {:validate, chain_uri, signature, body})
  end

  def handle_call({:validate, chain_uri, signature, body}, _from, state) do
    if uri_from_amazon?(chain_uri) do
      case validate_certificates(chain_uri, state[chain_uri]) do
        {:ok, certificates} ->
          state = Map.put(state, chain_uri, certificates)
          [ certificate | _] = certificates

          case is_signature_valid?(certificate, signature, body) do
            {:ok} ->
              {:reply, :ok, state}
            {:error, reason} ->
              {:reply, {:error, reason}, state}
          end

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    else
      {:reply, {:error, :not_amazon}, state}
    end
  end

  def validate_certificates(chain_uri, nil) do
    case HTTPoison.get(chain_uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        certificates = :public_key.pem_decode(body)
        validate_certificates(chain_uri, certificates)
      {_, _} ->
        {:error, :no_cert}
    end
  end

  def validate_certificates(_chain_uri, certificates) do
    decoded_certs(certificates)
    |> valid_chain?
  end

  def is_signature_valid?(certificate, signature, body) do
    Alexa.Records.certificate(tbsCertificate: tbs_certificate) = certificate
    certificate_from_amazon?(certificate)
    |> verify_signature(tbs_certificate, signature, body)
  end

  defp verify_signature(true, tbs_certificate, signature, body) do
    Alexa.Records.tbs_certificate(subjectPublicKeyInfo: public_key_info) = tbs_certificate
    Alexa.Records.subject_public_key_info(subjectPublicKey: key) = public_key_info
    {:ok, signature} = Base.decode64(signature)

    case :public_key.verify(body, :sha, signature, key) do
      true ->
        {:ok}
      false ->
        {:error, :invalid_signature}
    end
  end

  defp verify_signature(false, _, _, _) do
    {:error, :not_amazon}
  end

  defp decoded_certs(certificates) do
    Enum.map(certificates, fn({_, cert, _}) ->
      :public_key.pkix_decode_cert(cert, :otp)
    end)
  end

  defp valid_chain?(decoded_certs) do
    valid_chain = Enum.reduce(decoded_certs, true, fn(cert, acc) ->
      Alexa.Records.certificate(tbsCertificate: tbsCertificate) = cert
      Alexa.Records.tbs_certificate(validity: v) = tbsCertificate
      Alexa.Records.validity(notBefore: before) = v
      Alexa.Records.validity(notAfter: until) = v
      {_, not_before} = before
      {_, not_after} = until
      {:ok, not_before} = Timex.parse("#{not_before}", "{ASN1:UTCtime}")
      {:ok, not_after} = Timex.parse("#{not_after}", "{ASN1:UTCtime}")
      now = DateTime.utc_now
      acc && (DateTime.compare(not_before, now) == :lt && DateTime.compare(now, not_after) == :lt)
    end)
    if valid_chain do
      {:ok, decoded_certs}
    else
      {:error, :invalid_chain}
    end
  end

  defp uri_from_amazon?(uri) do
    uri = URI.parse(uri)
    uri.scheme == "https" && uri.host == "s3.amazonaws.com" && (uri.port == nil || uri.port == 443) && String.starts_with?(uri.path, "/echo.api")
  end

  defp certificate_from_amazon?(certificate) do
    Alexa.Records.certificate(tbsCertificate: tbs_certificate) = certificate
    Alexa.Records.tbs_certificate(extensions: extensions) = tbs_certificate
    Enum.reduce(extensions, false, fn(extension, acc) ->
      acc || case extension do
        {_, {2, 5, 29, 17}, _, [dNSName: 'echo-api.amazon.com']} ->
          true
        _ ->
          false
      end
    end)
  end

end
