require "active_support/core_ext/hash"
require "sneakers/security_utils"

module Sneakers
  class VerifiedPayload
    def initialize(hash)
      @hash = hash.deep_stringify_keys
    end

    def sign(app_name)
      Signature.sign(app_name, key_for(app_name), @hash)
    end

    def authentic?(signature)
      SecurityUtils.secure_compare(
        signature,
        sign(app_from_signature(signature)),
      )
    end

    private

    def app_from_signature(signature)
      signature.split(":").first
    end

    def key_for(app_name)
      SignedApplications.fetch(app_name).key
    end
  end
end
