require "base64"
require "digest/sha1"
require "sneakers/bencode_helper"

module Sneakers
  class Signature
    def self.sign(app, key, hash)
      new(app, key, hash).signature
    end

    def initialize(app, key, hash)
      @app = app
      @key = key
      @hash = hash
    end

    def signature
      "#{@app}:#{hmac(key, message)}"
    end

    private

    attr_reader :key

    def message
      BencodeHelper.bencode_with_booleans(@hash)
    end

    def hmac(key, message)
      Base64.strict_encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new("sha1"),
          key,
          message,
        ),
      )
    end
  end
end
