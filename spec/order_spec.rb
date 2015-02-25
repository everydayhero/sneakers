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
      [
        context: donation_context,
        merchant: donation_merchant,
        product: donation_product,
        quantity: 1,
        amount: TestHelpers.ten_dollars,
        amount_discount: TestHelpers.zero_dollars,
        data: {
          page_id: donation_page_id,
          thank_as: "Anonymous",
          message: "Cool",
          opt_in: true,
        },
      ]
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
        amount: TestHelpers.ten_dollars,
        thank_as: "Anonymous",
        message: "Cool",
        opt_in: true,
      }
    end

    let(:manifest_entry) do
      signed_manifest_entry.merge(unsigned_manifest_entry)
    end

    let(:order_hash) do
      {
        id: donation_id,
        region: donation_region,
        timestamp: donation_time,
        payer: TestHelpers.payer_hash,
        manifest: [manifest_entry],
        funding: TestHelpers.tns_funding_hash,
      }
    end

    let(:partial_order_hash) do
      {
        id: donation_id,
        region: donation_region,
        timestamp: donation_time,
        manifest: [signed_manifest_entry],
      }
    end

    let(:donation_app) { "supporter" }
    let(:donation_app_key) { SecureRandom.uuid }

    let(:signature) do
      Sneakers::Signature.sign(
        donation_app,
        donation_app_key,
        partial_order_hash,
      )
    end

    let(:expected_dto) do
      {
        id: donation_id,
        region: donation_region,
        timestamp: donation_time,
        payer: TestHelpers.payer_hash,
        manifest: manifest_dto,
        funding: TestHelpers.tns_funding_hash,
      }
    end

    let(:order) { Order.new(order_hash, signature: signature) }

    around do |example|
      SignedApplications.register(
        donation_app,
        donation_app_key,
        %i(
          context
          merchant
          product
          quantity
          amount_discount
          page_id
        ),
        %i(
          amount
          page_id
          thank_as
          message
          opt_in
        )
      )

      example.run

      SignedApplications.deregister(donation_app)
    end

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
      hash[:id] = "1234"
      order = Order.new(hash, signature: signature)

      expect(order).to_not be_authentic
      expect(order).to be_valid
    end

    it "can sign an order" do
      order = Order.new(order_hash, app_name: "supporter")
      expect(order.signature).to eq signature
      expect(order.hash).to eq order_hash
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
