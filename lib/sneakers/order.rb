require "active_support/core_ext/hash"

module Sneakers
  class Order
    attr_reader :hash

    def initialize(hash, signature: nil, app_name: nil)
      @hash = hash
      unless signature || app_name
        raise "must specify either signature or app_name"
      end
      @signature = signature
      @app_name = app_name
    end

    def self.supporter_donation(id, region, context, merchant, page_id, time)
      data = {
        id: id,
        region: region,
        timestamp: time,
        manifest: [
          {
            context: context,
            merchant: merchant,
            product: "p2p_donation",
            quantity: 1,
            amount_discount: {fractional: "0", currency: "AUD"},
            page_id: page_id,
          },
        ],
      }

      new(data, app_name: "supporter_donation")
    end

    def self.charity_profile_donation(id, region, context, merchant, timestamp)
      data = {
        id: id,
        region: region,
        timestamp: timestamp,
        manifest: [
          {
            context: context,
            merchant: merchant,
            product: "direct_donation",
            quantity: 1,
            amount_discount: {fractional: "0", currency: "AUD"},
          },
        ],
      }

      new(data, app_name: "charity_profile_donation")
    end

    def signature
      @signature ||= recalculated_signature
    end

    def authentic?
      signature == recalculated_signature
    end

    def valid?
      base_valid? && manifest_valid?
    end

    def base_valid?
      @hash.keys.all? do |key|
        BASE_KEYS.include?(key.to_sym) && !@hash[key].blank?
      end
    end

    def manifest_valid?
      @hash.fetch(:manifest).all? do |entry|
        entry.keys.all? do |key|
          app.attributes.include?(key.to_sym)
        end
      end
    end

    BASE_SIGNED = %i(
      id
      region
      timestamp
    )

    BASE_KEYS = BASE_SIGNED + %i(
      manifest
      signature
      payer
      funding
    )

    def partial_order_hash
      @hash.slice(*BASE_SIGNED).merge(
        manifest: partial_manifest,
      )
    end

    def dto
      @hash.except(:manifest).merge(manifest: manifest_dto)
    end

    # XXX: Order Refactoring gets rid of this
    def current_dto
      raise "single-manifest only" if manifest_dto.size != 1
      financial_context_id = manifest_dto.first["context"]
      merchant_id = manifest_dto.first["merchant"]
      manifest = [manifest_dto.first.values_at("product", "quantity", "amount")]
      {
        donation_id: dto[:id],
        region_code: dto[:region],
        financial_context_id: financial_context_id,
        merchant_id: merchant_id,
        manifest: {
          currency: "AUD",
          components: manifest,
        }.stringify_keys,
        funding: dto[:funding],
      }.stringify_keys
    end

    private

    REAL_MANIFEST = %i(
      context
      merchant
      product
      quantity
      amount
      amount_discount
    )

    def manifest_dto
      @hash.fetch(:manifest).map do |entry|
        entry.slice(*REAL_MANIFEST).merge(
          data: entry.except(*REAL_MANIFEST),
        )
      end
    end

    def recalculated_signature
      Signature.sign(app.name, app.key, partial_order_hash)
    end

    def app_name
      @app_name ||= signature.split(":").first
    end

    def app
      SignedApplications.fetch(app_name)
    end

    def app_signed_attributes
      app.signed_attributes
    end

    def partial_manifest
      @hash.fetch(:manifest).map do |entry|
        entry.slice(*app_signed_attributes)
      end
    end
  end
end
