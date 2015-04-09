require "active_support/core_ext/hash"

module Sneakers
  class Order
    attr_reader :hash

    def initialize(hash, signature: nil, app_name: nil)
      @hash = hash.deep_stringify_keys
      unless signature || app_name
        raise "must specify either signature or app_name"
      end
      @signature = signature
      @app_name = app_name
    end

    def self.supporter_donation(id, region, context, merchant, page_id, time)
      data = {
        order_id: id,
        region_code: region,
        timestamp: time,
        manifest: {
          currency: currency_of(region),
          components: [
            {
              context: context,
              merchant: merchant,
              product: "p2p_donation",
              quantity: 1,
              amount_discount: {amount: "0", currency: "AUD"},
              page_id: page_id,
            },
          ],
        }
      }

      new(data, app_name: "supporter_donation")
    end

    def self.charity_profile_donation(id, region, context, merchant, timestamp)
      data = {
        order_id: id,
        region_code: region,
        timestamp: timestamp,
        manifest: {
          currency: currency_of(region),
          components: [
            {
              context: context,
              merchant: merchant,
              product: "direct_donation",
              quantity: 1,
              amount_discount: {amount: "0", currency: "AUD"},
            }
          ],
        },
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
        BASE_KEYS.include?(key) && !@hash[key].blank?
      end
    end

    def manifest_valid?
      @hash.fetch('manifest').fetch('components').all? do |entry|
        entry.keys.all? do |key|
          app.attributes.map(&:to_s).include?(key)
        end
      end
    end

    BASE_SIGNED = %w(
      order_id
      region_code
      timestamp
    )

    BASE_KEYS = BASE_SIGNED + %w(
      manifest
      signature
      payer
      funding
    )

    def partial_order_hash
      @hash.slice(*BASE_SIGNED).merge('manifest' => partial_manifest)
    end

    def dto
      @hash.except('manifest').merge('manifest' => manifest_dto)
    end

    private

    REAL_MANIFEST = %w(
      context
      merchant
      product
      quantity
      amount
      amount_discount
    )

    def manifest_dto
      @hash.fetch('manifest').dup.tap do |manifest|
        manifest['components'] = manifest['components'].map do |component|
          component.slice(*REAL_MANIFEST).merge(
            'data' => component.except(*REAL_MANIFEST),
          )
        end
      end
    end

    def partial_manifest
      @hash.fetch('manifest').dup.tap do |manifest|
        manifest['components'] = manifest['components'].map do |component|
          component.slice(*app_signed_attributes)
        end
      end
    end

    private_class_method def self.currency_of(region_code)
      {
        au: "AUD",
      }.fetch(region_code.to_sym)
    end

    def region_code
      @hash["region_code"]
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
      app.signed_attributes.map(&:to_s)
    end
  end
end
