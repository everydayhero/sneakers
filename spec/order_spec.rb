require "spec_helper"

module Sneakers
  describe Order do
    let(:donation_region) { "au" }
    let(:donation_time) { Time.new(0).iso8601 }
    let(:donation_id) { "44cdf003-c065-4640-b23f-b55c05a60d5d" }
    let(:donation_context) { "b698a52b-546a-4025-bfac-a5db0ec677c4" }
    let(:donation_merchant) { "88190e57-3e13-4d28-aea2-daa0cf9523cf" }
    let(:donation_page_id) { 123 }
    let(:donation_product) { "p2p_donation" }

    let(:signed_manifest_entry) do
      {
        context: donation_context,
        merchant: donation_merchant,
        product: "p2p_donation",
        quantity: 1,
        amount_discount: TestHelpers.zero_dollars,
        page_id: donation_page_id,
      }
    end

    let(:unsigned_manifest_entry) do
      {
        amount_gross: TestHelpers.ten_dollars,
        donor: TestHelpers.payer_hash,
        opt_in_charity_communication: true,
        opt_in_resend_tax_receipt: true,
        supporter_donation_nickname: "Anonymous",
        supporter_donation_message: "Cool",
        anonymous_to_supporter: false,
      }
    end

    let(:manifest_entry) do
      signed_manifest_entry.merge(unsigned_manifest_entry)
    end

    let(:signed_manifest) do
      {
        currency: "AUD",
        components: [signed_manifest_entry],
      }
    end

    let(:manifest) do
      {
        currency: "AUD",
        components: [manifest_entry],
      }
    end

    let(:order_hash) do
      {
        order_id: donation_id,
        region_code: donation_region,
        timestamp: donation_time,
        payer: TestHelpers.payer_hash,
        manifest: manifest,
      }
    end

    let(:funded_order_hash) do
      order_hash.merge(
        funding: TestHelpers.tns_funding_hash,
      )
    end

    let(:app_key) { TestHelpers.supporter_donation_key }
    let(:app_name) { TestHelpers.supporter_donation_app_name }

    let(:signature) do
      Sneakers::Signature.sign(
        app_name,
        app_key,
        order_hash.except(:funding),
      )
    end

    let(:expected_dto) do
      {
        order_id: donation_id,
        region_code: donation_region,
        timestamp: donation_time,
        payer: TestHelpers.payer_hash,
        manifest: manifest_dto,
        funding: TestHelpers.tns_funding_hash,
      }.deep_stringify_keys
    end

    let(:order) { Order.new(order_hash, signature: signature) }

    it "a newly signed order is authentic" do
      order = Order.new(order_hash, signature: signature)

      expect(order).to be_authentic
    end

    it "a tampered order is inauthentic" do
      hash = order_hash.dup
      hash[:order_id] = "1234"
      order = Order.new(hash, signature: signature)

      expect(order).to_not be_authentic
    end

    it "ignores authenticity for funding" do
      order = Order.new(order_hash, app_name: TestHelpers.supporter_donation_app_name)
      expect(order).to be_authentic

      order_with_funding = Order.new(order.hash.merge("funding" => "something"), signature: order.signature)
      expect(order_with_funding).to be_authentic
    end

    it "knows that signing an order with funding is probably a huge mistake" do
      expect do
        order = Order.new(funded_order_hash, app_name: TestHelpers.supporter_donation_app_name)
      end.to raise_error
    end

    it "can sign an order" do
      order = Order.new(order_hash, app_name: TestHelpers.supporter_donation_app_name)
      expect(order.signature).to eq signature
      expect(order.hash).to eq order_hash.deep_stringify_keys
      expect(order.app_name).to eq TestHelpers.supporter_donation_app_name
    end
  end
end
