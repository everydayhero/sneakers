require "spec_helper"

module Sneakers
  RSpec.describe BlueprintBuilder do
    describe('#campaign_p2p') do
      let(:expected_hash) do
        {
          "complete": false,
          "gift": {
            "financial_context": {
              "id": "urn:edh:financial-context/cd48ef7c-78ad-4f5f-a6df-ae3db75892c3"
            },
            "region": "au",
            "type": "p2p",
            "tax_deductible": true,
            "donor_surcharging": true,
            "payment_instruments": [
              "credit_card",
              "offline",
              "paypal",
            ],
            "amount_cents": {
              "allow_arbitrary_amount": true,
              "plain": [20000, 10000, 5000]
            }
          },
          "app": {
            "collect": [
              "donor.email",
              "donor.name.given",
              "donor.name.family",
              "donor.telephone",
              "supporter.nickname",
              "supporter.anonymous_to_supporter",
              "supporter.message.optional",
              "donation.opt_in_charity_communication",
              "donation.opt_in_resend_tax_receipt"
            ]
          },
        }.deep_stringify_keys
      end

      it('creates the expected hash') do
        blueprint = BlueprintBuilder.campaign_p2p
        blueprint.region = "au"
        blueprint.financial_context = {
          "id": "urn:edh:financial-context/cd48ef7c-78ad-4f5f-a6df-ae3db75892c3"
        }
        blueprint.plain_amount_cents = [20000, 10000, 5000]
        blueprint.collect = [
          "donor.email",
          "donor.name.given",
          "donor.name.family",
          "donor.telephone",
          "supporter.nickname",
          "supporter.anonymous_to_supporter",
          "supporter.message.optional",
          "donation.opt_in_charity_communication",
          "donation.opt_in_resend_tax_receipt"
        ]
        expect(blueprint.serialize).to eq(expected_hash)
      end
    end

    describe('#page_p2p') do
      let(:expected_hash) do
        {
          "complete": true,
          "parent": "urn:edh:blueprint/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6",
          "gift": {
            "origin": {
              "id": "urn:edh:supporter-page/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6",
              "url": "http://give.example.com/au/foo",
              "share_url": "http://give.wtwalk.org/foo"
            },
            "beneficiary": {
              "id": "urn:edh:beneficiary/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6",
              "name": "Worldvision"
            },
            "expires_at": "2016-02-02T15:26:03+10:00"
          }
        }.deep_stringify_keys
      end

      it('creates the expected hash') do
        blueprint = BlueprintBuilder.page_p2p
        blueprint.parent = "urn:edh:blueprint/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6"
        blueprint.expires_at = Time.parse("2016-02-02T15:26:03+10:00")
        blueprint.origin = {
          "id": "urn:edh:supporter-page/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6",
          "url": "http://give.example.com/au/foo",
          "share_url": "http://give.wtwalk.org/foo"
        }
        blueprint.beneficiary = {
          "id": "urn:edh:beneficiary/5e3d9a6d-bc87-4d3a-bee2-6b44ecd2faa6",
          "name": "Worldvision"
        }
        expect(blueprint.serialize).to eq(expected_hash)
      end
    end
  end
end
