require "spec_helper"

module Sneakers
  RSpec.describe VerifiedPayload do
    let(:hash) { {foo: "bar", baz: "bala"} }
    let(:verified_payload) { described_class.new(hash) }
    let(:public_key) { "foo" }
    let(:secret_key) { "very-secret-key" }
    let(:signature) { "foo:v5mJKW74uUkBdXJ54TiQrvGk0fc=" }

    before { Sneakers::SignedApplications.register(public_key, secret_key) }

    describe "#sign" do
      it "returns signature" do
        expect(verified_payload.sign(public_key)).to eq(signature)
      end
    end

    describe "#authentic?" do
      context "with correct signature" do
        it "is authentic" do
          expect(verified_payload.authentic?(signature)).to be_truthy
        end
      end

      context "with incorrect signature" do
        it "is not authentic" do
          expect(verified_payload.authentic?("foo:wrong")).to be_falsy
        end
      end
    end
  end
end
