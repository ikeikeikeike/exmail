defmodule Exmail.Hash do
  require Logger

  @aes_256_key <<105, 165, 100, 175, 29, 1, 161, 74, 107, 189, 237, 3, 58, 72, 177, 28, 183,
                 59, 32, 15, 253, 250, 44, 210, 198, 12, 122, 32, 57, 216, 61, 40>>
  @iv <<23, 47, 162, 218, 4, 81, 179, 161, 0, 213, 217, 253, 82, 132, 125, 189>>
  @salt "exmailissalty;spike"

  def encrypt(text, opts \\ []) do
    iv = if opts[:random], do: ExCrypto.rand_bytes!(16), else: @iv
    with {:ok, {_ad, {init_vec, cipher_text, cipher_tag}}} <- ExCrypto.encrypt(@aes_256_key, @salt, iv, "#{text}"),
         {:ok, encoded_payload} <- encode_payload(init_vec, cipher_text, cipher_tag) do
      encoded_payload
    end
  end

  def decrypt(text) do
    with {:ok, {init_vec, cipher_text, cipher_tag}} <- decode_payload("#{normalize_decrypt text}"),
         {:ok, clear_text} = ExCrypto.decrypt(@aes_256_key, @salt, init_vec, cipher_text, cipher_tag) do
      clear_text
    end
  end

  def encode_payload(initialization_vector, cipher_text, cipher_tag) do
    Base.encode16 initialization_vector <> cipher_text <> cipher_tag, case: :lower
  end

  def decode_payload(encoded_parts) do
    {:ok, decoded_parts} = Base.decode16 encoded_parts, case: :lower
    decoded_length = byte_size decoded_parts
    iv = Kernel.binary_part(decoded_parts, 0, 16)
    cipher_text = Kernel.binary_part decoded_parts, 16, (decoded_length - 32)
    cipher_tag = Kernel.binary_part decoded_parts, decoded_length, -16
    {:ok, {iv, cipher_text, cipher_tag}}
  end

  def randstring(len) do
    len
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, len)
  end

  @doc """
  Lose hash string manually.
  """
  def short(text) do
    hash = encrypt text
    String.slice hash, 63, String.length(hash)
  end

  def md5(text) do
    Base.encode16 :erlang.md5(text), case: :lower
  end

  def mailify(text) do
    Base.url_encode64("#{text}")
  end

  # Decode text with previous encode at the same time.
  def unmailify(text) do
    try do
      decrypt text
    rescue MatchError ->
      case Base.url_decode64 "#{text}" do
        {:ok, dec} ->
          dec
        _error ->
          Logger.warn fn -> "[unmailify] #{inspect text}" end
          text
      end
    end
  end

  defp normalize_decrypt(text) do
    String.replace text, ["!", " "], ""
  end

  def mailer_id(name, ids) when is_list(ids) do
    "#{name} Mailer - **CID#{Enum.join(ids, "")}**"
  end
  def mailer_id(name, id) do
    mailer_id name, [id]
  end

  def idify(name, ids) when is_list(ids) do
    "#{name}-#{Enum.join(ids, ".")}"
  end
  def idify(name, id) do
    idify name, [id]
  end

  def unidify(text) do
    String.split(text, "-")
    |> List.last
    |> String.split(".")
  end

end
