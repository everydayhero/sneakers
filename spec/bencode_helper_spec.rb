require "sneakers/bencode_helper"

RSpec.describe Sneakers::BencodeHelper do
  it "should encode true" do
    expect do
      Sneakers::BencodeHelper.bencode_object_graph({foo: true})
    end.not_to raise_error
  end

  it "should encode false" do
    expect do
      Sneakers::BencodeHelper.bencode_object_graph({foo: false})
    end.not_to raise_error
  end

  it "should encode nil" do
    expect do
      Sneakers::BencodeHelper.bencode_object_graph({foo: nil})
    end.not_to raise_error
  end
end
