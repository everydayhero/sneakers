require "base64"
require "digest/sha1"
require "sneakers/bencode_helper"

module Sneakers
  class Signature
    def self.sign(public_key, secret_key, hash)
      new(public_key, secret_key, hash).signature
    end

    def initialize(public_key, secret_key, hash)
      @public_key = public_key
      @secret_key = secret_key
      @hash = hash
    end

    def signature
      "#{@public_key}:#{hmac(secret_key, message)}"
    end

    private

    attr_reader :secret_key

    def message
      BencodeHelper.bencode_object_graph(@hash)
    end

    def hmac(secret_key, message)
      Base64.strict_encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new("sha1"),
          secret_key,
          message,
        ),
      )
    end
  end
end
