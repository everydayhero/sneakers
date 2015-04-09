require "spec_helper"

module Sneakers
  describe Order do
    let(:region_code) { "au" }
    let(:financial_context_id) { SecureRandom.uuid }
    let(:merchant_id) { SecureRandom.uuid }
    let(:timestamp) { Time.new(0).iso8601 }
    let(:donation_id) { SecureRandom.uuid }

    context ".supporter_donation" do
      let(:app_name) { TestHelpers.supporter_donation_app_name }
      let(:app_key) { TestHelpers.supporter_donation_key }
      let(:page_id) { SecureRandom.uuid }
      let(:valid_signature) do
        Signature.sign(
          app_name,
          app_key,
          order_id: donation_id,
          region_code: region_code,
          timestamp: timestamp,
          manifest: {
            currency: "AUD",
            components: [
              {
                context: financial_context_id,
                merchant: merchant_id,
                product: "p2p_donation",
                quantity: 1,
                amount_discount: TestHelpers.zero_dollars,
                page_id: page_id,
              },
            ],
          },
        )
      end

      it "can create orders" do
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
            order_id: donation_id,
            region_code: region_code,
            timestamp: timestamp,
            manifest: {
              currency: "AUD",
              components: [
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
            }
          },
          signature: signed_order.signature,
        )

        expect(order).to be_authentic
        expect(order).to be_valid
      end
    end

    context ".charity_profile_donation" do
      let(:app_name) { "charity_profile_donation" }
      let(:app_key) { ENV.fetch("CHARITY_PROFILE_DONATION_KEY") }
      let(:valid_signature) do
        Signature.sign(
          app_name,
          app_key,
          order_id: donation_id,
          region_code: region_code,
          timestamp: timestamp,
          manifest: {
            currency: "AUD",
            components: [
              {
                context: financial_context_id,
                merchant: merchant_id,
                product: "direct_donation",
                quantity: 1,
                amount_discount: TestHelpers.zero_dollars,
              },
            ],
          },
        )
      end

      it "can create orders" do
        signed_order = Order.charity_profile_donation(
          donation_id,
          region_code,
          financial_context_id,
          merchant_id,
          timestamp,
        )

        expect(signed_order.signature).to eq(valid_signature)

        order = Order.new(
          {
            order_id: donation_id,
            region_code: region_code,
            timestamp: timestamp,
            manifest: {
              currency: "AUD",
              components: [
                {
                  context: financial_context_id,
                  merchant: merchant_id,
                  product: "direct_donation",
                  quantity: 1,
                  amount_discount: TestHelpers.zero_dollars,
                  amount: TestHelpers.ten_dollars,
                },
              ],
            },
          },
          signature: signed_order.signature,
        )

        expect(order).to be_authentic
        expect(order).to be_valid
      end
    end
  end
end
