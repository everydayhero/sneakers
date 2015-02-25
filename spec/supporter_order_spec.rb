require "spec_helper"
require "sneakers/registered_applications"

module Sneakers
  describe Order do
    let(:region_code) { "au" }
    let(:financial_context_id) { SecureRandom.uuid }
    let(:merchant_id) { SecureRandom.uuid }
    let(:timestamp) { Time.new(0).iso8601 }
    let(:donation_id) { SecureRandom.uuid }

    context ".supporter_donation" do
      let(:app_name) { "supporter_donation" }
      let(:app_key) { "123" }
      let(:page_id) { SecureRandom.uuid }
      let(:valid_signature) do
        Signature.sign(
          app_name,
          app_key,
          id: donation_id,
          region: region_code,
          timestamp: timestamp,
          manifest: [
            {
              context: financial_context_id,
              merchant: merchant_id,
              product: "p2p_donation",
              quantity: 1,
              amount_discount: TestHelpers.zero_dollars,
              page_id: page_id,
            },
          ],
        )
      end

      it "can create orders for supporter_donation" do
        signed_order = Order.supporter_donation(
          donation_id,
          region_code,
          financial_context_id,
          merchant_id,
          page_id,
          timestamp,
        )

        expect(signed_order.signature).to eq(valid_signature)

        order = Order.new(
          {
            id: donation_id,
            region: region_code,
            timestamp: timestamp,
            manifest: [
              {
                context: financial_context_id,
                merchant: merchant_id,
                product: "p2p_donation",
                quantity: 1,
                amount_discount: TestHelpers.zero_dollars,
                page_id: page_id,
                amount: TestHelpers.ten_dollars,
              },
            ],
          },
          signature: signed_order.signature,
        )

        expect(order).to be_authentic
        expect(order).to be_valid
      end
    end
  end
end
