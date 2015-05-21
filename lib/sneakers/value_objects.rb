require 'virtus'
require "active_support/core_ext/hash"

module Sneakers
  module ValueObjects
    module VirtusSerializable
      def serialize
        to_h.each_with_object({}) do |(key, value), hash|
          if value.respond_to?(:serialize)
            hash[key] = value.serialize
          elsif value.respond_to?(:to_ary)
            hash[key] = value.map do |item|
              if item.respond_to?(:serialize)
                item.serialize
              else
                item
              end
            end
          elsif value
            hash[key] = value
          else
          end
        end.deep_stringify_keys
      end
    end

    class Name
      include VirtusSerializable
      include Virtus.model

      attribute :prefix, String
      attribute :given, String
      attribute :additional, String
      attribute :family, String
      attribute :suffix, String
    end

    class Address
      include VirtusSerializable
      include Virtus.model

      attribute :street_address, String
      attribute :locality, String
      attribute :region, String
      attribute :postal_code, String
      attribute :country, String
    end

    class Person
      include VirtusSerializable
      include Virtus.model

      attribute :name, Name
      attribute :email, String
      attribute :telephone, String
      attribute :address, Address
    end

    module Donations
      class Donation
        include VirtusSerializable
        include Virtus.model

        attribute :opt_in_charity_communication, Axiom::Types::Boolean
        attribute :opt_in_resend_tax_receipt, Axiom::Types::Boolean
        attribute :donor, Person
      end

      class SupporterDonation < Donation
        attribute :page_id, Integer
        attribute :supporter_donation_nickname, String
        attribute :supporter_donation_message, String
        attribute :anonymous_to_supporter, Axiom::Types::Boolean
      end
    end

    module Payments
      class Money
        include VirtusSerializable
        include Virtus.model

        attribute :amount, BigDecimal
        attribute :currency, String

        def self.zero(currency)
          new(amount: BigDecimal.new(0), currency: currency)
        end

        def serialize
          super.tap do |hash|
            hash["amount"] = hash["amount"].to_s("F")
          end
        end
      end

      class ManifestItem
        include VirtusSerializable
        include Virtus.model

        attribute :context, String
        attribute :merchant, String
        attribute :product, String
        attribute :quantity, Integer
        attribute :amount_gross, Money
        attribute :amount_discount, Money
        attribute :extra, Hash

        def serialize
          super.values_at(*%w(
            context
            merchant
            product
            quantity
            amount_gross
            amount_discount
            extra
          ))
        end
      end

      class Manifest
        include VirtusSerializable
        include Virtus.model

        attribute :currency, String
        attribute :components, Array[ManifestItem]
      end

      class Order
        include VirtusSerializable
        include Virtus.model

        attribute :order_id, String
        attribute :region_code, String
        attribute :timestamp, String
        attribute :payer, Person
        attribute :manifest, Manifest
      end
    end
  end
end
