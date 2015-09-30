require "active_support/core_ext/hash"
require "sneakers/security_utils"

module Sneakers
  class Order
    UNSIGNED_PORTION = %w(
      funding
    )

    AttemptedToSignFundedOrder = Class.new(StandardError)

    def initialize(hash, signature: nil, public_key: nil)
      @hash = hash.deep_stringify_keys

      unless signature || public_key
        raise "must specify either signature or public_key"
      end

      @signature = signature
      @public_key = public_key

      raise AttemptedToSignFundedOrder if attempted_to_sign_funded_order?
    end

    attr_reader :hash

    def signature
      @signature ||= recalculated_signature
    end

    def public_key
      @public_key ||= signature.split(":").first
    end
    alias_method :app_name, :public_key

    def authentic?
      SecurityUtils.secure_compare(signature, recalculated_signature)
    end

    private

    def attempted_to_sign_funded_order?
      @signature.nil? && @hash.key?("funding")
    end

    def recalculated_signature
      Signature.sign(app.public_key, app.secret_key, hash.except(*UNSIGNED_PORTION))
    end

    def app
      SignedApplications.fetch(public_key)
    end
  end
end
