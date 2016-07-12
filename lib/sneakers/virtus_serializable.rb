require "active_support/concern"
require "active_support/core_ext/hash"
require 'virtus'

module Sneakers
  module VirtusSerializable
    extend ActiveSupport::Concern

    included do
      include Virtus.value_object
    end

    def serialize
      to_h.each_with_object({}) do |(key, value), hash|
        if value.respond_to?(:serialize)
          hash[key] = value.serialize
        elsif value.respond_to?(:to_ary)
          hash[key] = value.map do |item|
            if item.respond_to?(:serialize)
              item.serialize
            else
              item
            end
          end
        elsif value || FalseClass === value
          hash[key] = value
        else
        end
      end.deep_stringify_keys
    end
  end
end
