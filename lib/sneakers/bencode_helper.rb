require "bencode"

module Sneakers
  module BencodeHelper
    module_function \
    def transform(value)
      case value
      when Array
        value.map { |v| transform(v) }
      when Hash
        value.each_with_object({}) { |(h,k), hh| hh[h] = transform(k) }
      when true
        "true"
      when false
        "false"
      when nil
        ""
      else
        value
      end
    end

    module_function \
    def bencode_object_graph(object)
      transform(object).bencode
    end
  end
end
