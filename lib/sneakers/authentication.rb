require "sneakers"
require "active_support/security_utils"

module Sneakers
  class Order
    def authentic?
      ActiveSupport::SecurityUtils.secure_compare(signature, recalculated_signature)
    end
  end
end
