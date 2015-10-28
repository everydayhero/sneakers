require "spec_helper"

RSpec.describe Sneakers::ValueObjects::Payments::OrderFees do
  let(:fees) do
    {
      fees: {
        components: [
          {
            name: "p2p_donation",
            amount: {
              amount: "39.5",
              currency: "AUD",
            }
          }
        ]
      }
    }.deep_stringify_keys
  end

  it "parses fees" do
    order_fees = described_class.new(fees)
    expect(order_fees.serialize).to eq(fees)
  end
end
