require "spec_helper"

module Sneakers
  describe SignedApplications do
    let(:public_key) { TestHelpers.supporter_donation_public_key }
    let(:secret_key) { TestHelpers.supporter_donation_secret_key }
    let(:app) { SignedApplications.fetch(public_key) }

    it "should retrieve an app's secret key" do
      expect(app.secret_key).to eq(secret_key)
    end
  end
end
