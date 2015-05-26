require "spec_helper"

module Sneakers
  describe SignedApplications do
    let(:app_name) { TestHelpers.supporter_donation_app_name }
    let(:key) { TestHelpers.supporter_donation_key }
    let(:app) { SignedApplications.fetch(app_name) }

    it "should retrieve an app's key" do
      expect(app.key).to eq(key)
    end
  end
end
