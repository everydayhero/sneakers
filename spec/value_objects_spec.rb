require "spec_helper"

RSpec.describe Sneakers::ValueObjects::Payments::OrderFees do
  let(:fees) do
    {
      fees: {
        components: [
          {
            name: "surcharge_adjustment",
            amount: {
              amount: "39.5",
              currency: "AUD",
            }
          },
          {
            name: "p2p_donation",
            amount: {
              amount: "41.5",
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

  it "finds fee by name" do
    fee = described_class.new(fees).find_by_name("p2p_donation")
    expect(fee.amount.amount).to eq(41.5)
    expect(fee.name).to eq("p2p_donation")
  end
end
