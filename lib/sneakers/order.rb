require "active_support/core_ext/hash"

module Sneakers
  class Order
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

    REAL_MANIFEST = %w(
      context
      merchant
      product
      quantity
      amount_gross
      amount_discount
    )

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

    def initialize(hash, signature: nil, app_name: nil)
      @hash = hash.deep_stringify_keys
      unless signature || app_name
        raise "must specify either signature or app_name"
      end
      @signature = signature
      @app_name = app_name
    end

    attr_reader :hash

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
          app.attributes.include?(key)
        end
      end
    end

    def partial_order_hash
      @hash.slice(*BASE_SIGNED).merge('manifest' => partial_manifest)
    end

    def dto
      @hash.except('manifest').merge('manifest' => manifest_dto)
    end

    private

    # TODO: parameterize currency in factory methods
    private_class_method def self.currency_of(region_code)
      {
        au: "AUD",
        ie: "EUR",
      }.fetch(region_code.to_sym)
    end

    def manifest_dto
      transform_manifest_components do |component|
        component.slice(*REAL_MANIFEST).merge(
          'extra' => component.except(*REAL_MANIFEST),
        ).values
      end
    end

    def partial_manifest
      transform_manifest_components do |component|
        component.slice(*app_signed_attributes)
      end
    end

    def transform_manifest_components
      @hash.fetch('manifest').dup.tap do |manifest|
        manifest['components'] = manifest['components'].map do |component|
          yield component
        end
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
  end
end
