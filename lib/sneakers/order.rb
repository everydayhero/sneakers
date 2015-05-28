require "active_support/core_ext/hash"

module Sneakers
  class Order
    UNSIGNED_PORTION = %w(
      funding
    )

    AttemptedToSignFundedOrder = Class.new(StandardError)

    def initialize(hash, signature: nil, app_name: nil)
      @hash = hash.deep_stringify_keys

      unless signature || app_name
        raise "must specify either signature or app_name"
      end

      @signature = signature
      @app_name = app_name

      raise AttemptedToSignFundedOrder if attempted_to_sign_funded_order?
    end

    attr_reader :hash

    def signature
      @signature ||= recalculated_signature
    end

    private

    def attempted_to_sign_funded_order?
      @signature.nil? && @hash.key?("funding")
    end

    def recalculated_signature
      Signature.sign(app.name, app.key, hash.except(*UNSIGNED_PORTION))
    end

    def app_name
      @app_name ||= signature.split(":").first
    end

    def app
      SignedApplications.fetch(app_name)
    end
  end
end
