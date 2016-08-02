require "sneakers/value_objects"

module Sneakers
  class BlueprintBuilder
    def self.campaign_p2p
      default = {
        complete: false,
        gift: {
          type: "p2p",
          tax_deductible: true,
          donor_surcharging: true,
          payment_instruments: [
            "credit_card",
            "offline",
            "paypal"
          ],
          "amount_cents": {
            "allow_arbitrary_amount": true,
          }
        },
        app: {
          collect: []
        }
      }
      new(default)
    end

    def self.page_p2p
      default = {
        "complete": true,
      }
      new(default)
    end

    def initialize(blueprint)
      @blueprint = blueprint
    end

    def value_object
      ValueObjects::Blueprints::Blueprint.new(@blueprint)
    end

    def serialize
      value_object.serialize
    end

    def region= value
      @blueprint.deep_merge!(gift: {region: value })
    end

    def expires_at= value
      @blueprint.deep_merge!(gift: {expires_at: value.iso8601})
    end

    def parent= value
      @blueprint.deep_merge!(parent: value)
    end

    def origin= value
      @blueprint.deep_merge!(gift: {origin: value})
    end

    def beneficiary= value
      @blueprint.deep_merge!(gift: {beneficiary: value})
    end

    def financial_context= value
      @blueprint.deep_merge!(gift: {financial_context: value})
    end

    def plain_amount_cents= value
      @blueprint.deep_merge!(gift: {amount_cents: {plain: value}})
    end

    def collect= value
      @blueprint.deep_merge!(app: {collect: value})
    end
  end
end
