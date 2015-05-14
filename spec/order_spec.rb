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

    let(:manifest_dto) do
      {
        currency: "AUD",
        components: [[
          donation_context,
          donation_merchant,
          donation_product,
          1,
          TestHelpers.ten_dollars,
          TestHelpers.zero_dollars,
          {
            donor: TestHelpers.payer_hash,
            opt_in_charity_communication: true,
            opt_in_resend_tax_receipt: true,
            page_id: donation_page_id,
            supporter_donation_nickname: "Anonymous",
            supporter_donation_message: "Cool",
            anonymous_to_supporter: false,
          },
        ]],
      }.deep_stringify_keys
    end

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
        funding: TestHelpers.tns_funding_hash,
      }
    end

    let(:partial_order_hash) do
      {
        order_id: donation_id,
        region_code: donation_region,
        timestamp: donation_time,
        manifest: signed_manifest,
      }.deep_stringify_keys
    end

    let(:app_key) { TestHelpers.supporter_donation_key }
    let(:app_name) { TestHelpers.supporter_donation_app_name }

    let(:signature) do
      Sneakers::Signature.sign(
        app_name,
        app_key,
        partial_order_hash,
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

    it "can extract extract the partial order" do
      expect(order.partial_order_hash).to eq(partial_order_hash)
    end

    it "a signed, valid order" do
      order = Order.new(order_hash, signature: signature)

      expect(order).to be_authentic
      expect(order).to be_valid
    end

    it "an inauthentic, valid order" do
      hash = order_hash
      hash["order_id"] = "1234"
      order = Order.new(hash, signature: signature)

      expect(order).to_not be_authentic
      expect(order).to be_valid
    end

    it "can sign an order" do
      order = Order.new(order_hash, app_name: TestHelpers.supporter_donation_app_name)
      expect(order.signature).to eq signature
      expect(order.hash).to eq order_hash.deep_stringify_keys
    end

    it "an authentic, invalid order" do
      hash = order_hash
      hash[:extra] = "1234"
      order = Order.new(hash, signature: signature)

      expect(order).to be_authentic
      expect(order).to_not be_valid
    end

    it "turns into a dto" do
      expect(order.dto).to eq(expected_dto)
    end
  end
end
