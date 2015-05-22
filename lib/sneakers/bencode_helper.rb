require "bencode"

module Sneakers
  module BencodeHelper
    module_function \
    def transform(value)
      if value.is_a?(Array)
        value.map { |v| transform(v) }
      elsif value.is_a?(Hash)
        value.each_with_object({}) { |(h,k), hh| hh[h] = transform(k) }
      elsif value == true
        "true"
      elsif value == false
        "false"
      else
        value
      end
    end

    module_function \
    def bencode_with_booleans(object)
      transform(object).bencode
    end
  end
end
