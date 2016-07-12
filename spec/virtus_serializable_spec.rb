require "spec_helper"

module Sneakers
  describe VirtusSerializable do
    class SerializableAttributes
      include VirtusSerializable

      attribute :string, String
      attribute :integer, Integer
      attribute :big_decimal, BigDecimal
      attribute :boolean, Axiom::Types::Boolean
    end

    it "serializes String" do
      serializer = SerializableAttributes.new(string: "Miley")

      expect(serializer.serialize).to eq("string" => "Miley")
    end

    it "serializes Integer" do
      serializer = SerializableAttributes.new(integer: 1)

      expect(serializer.serialize).to eq("integer" => 1)
    end

    it "serializes BigDecimal" do
      serializer = SerializableAttributes.new(big_decimal: BigDecimal("0.5"))

      expect(serializer.serialize).to eq("big_decimal" => BigDecimal("0.5"))
    end

    it "serializes Boolean" do
      true_serializer = SerializableAttributes.new(boolean: true)
      expect(true_serializer.serialize).to eq("boolean" => true)

      false_serializer = SerializableAttributes.new(boolean: false)
      expect(false_serializer.serialize).to eq("boolean" => false)
    end
  end
end
