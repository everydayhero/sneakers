require "spec_helper"

module Sneakers
  describe Application do
    let(:application) { Application.new("foo", "bar") }

    describe "#name" do
      it "fetches public_key" do
        expect(application.name).to eq("foo")
      end
    end

    describe "#key" do
      it "fetches secret_key" do
        expect(application.key).to eq("bar")
      end
    end
  end
end
