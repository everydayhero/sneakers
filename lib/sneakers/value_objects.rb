require "sneakers/virtus_serializable"

module Sneakers
  module ValueObjects
    class Name
      include VirtusSerializable

      attribute :prefix, String
      attribute :given, String
      attribute :additional, String
      attribute :family, String
      attribute :suffix, String
    end

    class Address
      include VirtusSerializable

      attribute :street_address, String
      attribute :locality, String
      attribute :region, String
      attribute :postal_code, String
      attribute :country, String
    end

    class Person
      include VirtusSerializable

      attribute :name, Name
      attribute :email, String
      attribute :telephone, String
      attribute :address, Address
    end

    module Donations
      class Donation
        include VirtusSerializable

        attribute :intended_gift_amount, String
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

        attribute :financial_context_id, String
        attribute :merchant_id, String
        attribute :product, String
        attribute :quantity, Integer
        attribute :amount_gross, Money
        attribute :amount_discount, Money
        attribute :extra, Hash

        alias :merchant :merchant_id
        alias :merchant= :merchant_id=
        alias :context :financial_context_id
        alias :context= :financial_context_id=

        public :context=
        public :merchant=

        def serialize
          super.values_at(*%w(
            financial_context_id
            merchant_id
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

        attribute :currency, String
        attribute :components, Array[ManifestItem]
      end

      class Order
        include VirtusSerializable

        attribute :order_id, String
        attribute :region_code, String
        attribute :timestamp, String
        attribute :payer, Person
        attribute :manifest, Manifest
      end

      class OrderFee
        include VirtusSerializable

        attribute :name, String
        attribute :amount, Money
      end

      class OrderFeesCollection
        include VirtusSerializable

        attribute :components, Array[OrderFee]
      end

      class OrderFees
        include VirtusSerializable

        attribute :fees, OrderFeesCollection
      end
    end
  end
end
