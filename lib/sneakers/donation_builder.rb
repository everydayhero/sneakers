require "sneakers/value_objects"
require "sneakers/order"

module Sneakers
  class DonationBuilder
    def self.supporter(region_code)
      new(
        region_code,
        "p2p_donation",
        ENV.fetch("SUPPORTER_DONATION_PUBLIC_KEY"),
      )
    end

    def self.charity_profile(region_code)
      new(
        region_code,
        "direct_donation",
        ENV.fetch("CHARITY_PROFILE_DONATION_PUBLIC_KEY"),
      )
    end

    def initialize(region_code, donation_type, public_key)
      @region_code = region_code
      @donation_type = donation_type
      @public_key = public_key
    end

    def currency
      {
        "au" => "AUD",
        "nz" => "NZD",
        "uk" => "GBP",
        "us" => "USD",
        "ie" => "EUR",
      }.fetch(@region_code)
    end

    def money_for(amount)
      ValueObjects::Payments::Money.new(amount: amount, currency: currency)
    end

    def build_manifest(context, merchant, product, quantity, amount, extra)
      ValueObjects::Payments::Manifest.new(
        currency: currency,
        components: [
          context: context,
          merchant: merchant,
          product: product,
          quantity: quantity,
          amount_gross: money_for(amount),
          amount_discount: ValueObjects::Payments::Money.zero(currency),
          extra: extra.serialize,
        ]
      )
    end

    def donation_for(supporter_donation, id, context, merchant, timestamp, payer, amount)
      ValueObjects::Payments::Order.new(
        order_id: id,
        region_code: @region_code,
        timestamp: timestamp,
        payer: payer,
        manifest: build_manifest(context, merchant, @donation_type, 1, amount, supporter_donation)
      )
    end

    def order(*args)
      Order.new(
        donation_for(*args).serialize,
        public_key: @public_key,
      )
    end
  end
end
