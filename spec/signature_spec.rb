require "spec_helper"

require "sneakers/signature"

module Sneakers
  describe Signature do
    let(:public_key) { "supporter-public-key" }
    let(:secret_key) { "supporter-secret-key" }
    let(:hash) { {xdata: "blah", adata: "other"} }

    let(:message) { hash.bencode }

    let(:sha1) { OpenSSL::Digest.new("sha1") }
    let(:signature) { OpenSSL::HMAC.digest(sha1, secret_key, message) }
    let(:base64_signature) { Base64.strict_encode64(signature) }

    let(:calculated_signature) do
      [public_key, base64_signature].join(":")
    end

    it "should sign things" do
      result = Signature.sign(public_key, secret_key, hash)
      expect(result).to eq calculated_signature
    end
  end
end
