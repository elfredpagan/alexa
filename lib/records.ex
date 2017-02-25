defmodule Alexa.Records do
  require Record
  import Record
  defrecord :certificate, :OTPCertificate, extract(:OTPCertificate, from_lib: "public_key/include/public_key.hrl")
  defrecord :tbs_certificate, :OTPTBSCertificate, extract(:OTPTBSCertificate, from_lib: "public_key/include/public_key.hrl")
  defrecord :signature_algorithm, :SignatureAlgorithm, extract(:SignatureAlgorithm, from_lib: "public_key/include/public_key.hrl")
  defrecord :public_key_algorithm, :PublicKeyAlgorithm, extract(:PublicKeyAlgorithm, from_lib: "public_key/include/public_key.hrl")
  defrecord :attribute, :AttributeTypeAndValue, extract(:AttributeTypeAndValue, from_lib: "public_key/include/public_key.hrl")
  defrecord :subject_public_key_info, :OTPSubjectPublicKeyInfo, extract(:OTPSubjectPublicKeyInfo, from_lib: "public_key/include/public_key.hrl")
  defrecord :extension, :Extension, extract(:Extension, from_lib: "public_key/include/public_key.hrl")
  defrecord :validity, :Validity, extract(:Validity, from_lib: "public_key/include/public_key.hrl")
end
