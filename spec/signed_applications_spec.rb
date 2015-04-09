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
        page_id
        product
        quantity
        amount_discount
      )
    end

    it "should retrieve a list of unsigned attributes" do
      expect(app.unsigned_attributes).to eq %w(
        amount
        thank_as
        message
        opt_in
      )
    end

    it "should have #attributes" do
      expect(app.attributes).to eq(
        app.signed_attributes + app.unsigned_attributes,
      )
    end
  end
end
