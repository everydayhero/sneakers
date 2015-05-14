require "spec_helper"

module Sneakers
  describe SignedApplications do
    let(:app_name) { TestHelpers.supporter_donation_app_name }
    let(:key) { TestHelpers.supporter_donation_key }
    let(:app) { SignedApplications.fetch(app_name) }

    it "should retrieve an app's key" do
      expect(app.key).to eq(key)
    end

    it "should retrieve a list of signed attributes" do
      expect(app.signed_attributes).to eq %w(
        context
        merchant
        product
        quantity
        amount_discount
        page_id
      )
    end

    it "should retrieve a list of unsigned attributes" do
      expect(app.unsigned_attributes).to eq %w(
        amount_gross
        payer
        donor
        opt_in_charity_communication
        opt_in_resend_tax_receipt
        supporter_donation_nickname
        supporter_donation_message
        anonymous_to_supporter
      )
    end

    it "should have #attributes" do
      expect(app.attributes).to eq(
        app.signed_attributes + app.unsigned_attributes,
      )
    end
  end
end
