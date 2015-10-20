require "spec_helper"

module Sneakers
  RSpec.describe DonationBuilder do
    let(:order_id) { SecureRandom.uuid }
    let(:context) { SecureRandom.uuid }
    let(:merchant) { SecureRandom.uuid }

    let(:timestamp) { Time.new }

    let(:expected_hash) do
      {
        order_id: order_id,
        region_code: 'au',
        timestamp:  timestamp.rfc2822,
        payer: {
          name: {
            given: 'Foo',
            family: 'Foonly'
          },
          email: 'foo@example.com'
        },
        manifest: {
          currency: "AUD",
          components: [
            [
              context,
              merchant,
              "p2p_donation",
              1,
              { amount: '1000.0', currency: 'AUD' },
              { amount: '0.0', currency: 'AUD' },
              {
                donor: {
                  name: {
                    given: 'Foo',
                    family: 'Foonly'
                  },
                  email: 'foo@example.com'
                },
                page_id: 5,
                supporter_donation_nickname: 'Fooner',
                supporter_donation_message: 'Great Work'
              }
            ]
          ],
        },
      }.deep_stringify_keys
    end

    let(:person) do
      Sneakers::ValueObjects::Person.new(
        name: { given: 'Foo', family: 'Foonly' },
        email: 'foo@example.com'
      )
    end

    let(:supporter_donation) do
      Sneakers::ValueObjects::Donations::SupporterDonation.new(
        page_id: 5,
        donor: person,
        supporter_donation_nickname: 'Fooner',
        supporter_donation_message: 'Great Work'
      )
    end

    it 'should generate compatible hashes' do
      donation_order = Sneakers::DonationBuilder.supporter('au')
        .donation_for(
          supporter_donation,
          order_id,
          context,
          merchant,
          timestamp.rfc2822,
          person,
          '1000'.to_d
        )

      expect(donation_order.serialize).to eq(expected_hash)
    end

    let(:order) do
      Sneakers::DonationBuilder.supporter('au').order(
        supporter_donation,
        order_id,
        context,
        merchant,
        timestamp.rfc2822,
        person,
        '1000'.to_d
      )
    end

    it "should generate authentic orders" do
      expect(order).to be_authentic
    end

    it "should generate signatures that are authentic" do
      order2 = Sneakers::Order.new(order.hash, signature: order.signature)
      expect(order2).to be_authentic
    end

    it "should ignore funding for authenticity purposes" do
      funded_order = order.hash.merge("funding" => {"via" => "tns"})

      order2 = Sneakers::Order.new(funded_order, signature: order.signature)
      expect(order2).to be_authentic
    end
  end
end
