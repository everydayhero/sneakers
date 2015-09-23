# Stolen from ActiveSupport::SecurityUtils
# https://github.com/rails/rails/blob/c8c6600/activesupport/lib/active_support/security_utils.rb

module Sneakers
  module SecurityUtils
    module_function def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end
