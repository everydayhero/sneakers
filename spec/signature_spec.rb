require "spec_helper"

require "sneakers/signature"

module Sneakers
  describe Signature do
    let(:app) { "supporter" }
    let(:key) { "supporter-key" }
    let(:hash) { {xdata: "blah", adata: "other"} }

    let(:message) { hash.bencode }

    let(:sha1) { OpenSSL::Digest.new("sha1") }
    let(:signature) do
      OpenSSL::HMAC.digest(sha1, key, message)
    end
    let(:base64_signature) { Base64.strict_encode64(signature) }

    let(:calculated_signature) do
      [app, base64_signature].join(":")
    end

    it "should sign things" do
      expect(Signature.sign(app, key, hash)).to eq calculated_signature
    end
  end
end
