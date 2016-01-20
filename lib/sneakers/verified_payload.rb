require "active_support/core_ext/hash"
require "sneakers/security_utils"

module Sneakers
  class VerifiedPayload
    def initialize(payload)
      @payload = payload.deep_stringify_keys
    end

    attr_reader :payload

    def sign(public_key)
      Signature.sign(public_key, secret_key_for(public_key), @payload)
    end

    def authentic?(signature)
      SecurityUtils.secure_compare(
        signature,
        sign(public_key_from_signature(signature)),
      )
    end

    private

    def public_key_from_signature(signature)
      signature.split(":").first
    end

    def secret_key_for(public_key)
      SignedApplications.fetch(public_key).secret_key
    end
  end
end
