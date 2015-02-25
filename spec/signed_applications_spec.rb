require "spec_helper"

require "sneakers/signed_applications"

module Sneakers
  describe SignedApplications do
    let(:app_name) { "supporter" }
    let(:key) { SecureRandom.uuid }

    around do |example|
      SignedApplications.register(
        app_name,
        key,
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

      SignedApplications.deregister(app_name)
    end

    let(:app) { SignedApplications.fetch(app_name) }

    it "should retrieve an app's key" do
      expect(app.key).to eq(key)
    end

    it "should retrieve a list of signed attributes" do
      expect(app.signed_attributes).to eq %i(
        context
        merchant
        product
        quantity
        amount_discount
        page_id
      )
    end

    it "should retrieve a list of unsigned attributes" do
      expect(app.unsigned_attributes).to eq %i(
        amount
        page_id
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
