require "sneakers/version"

module Sneakers
end

require "sneakers/order"
require "sneakers/donation_builder"
require "sneakers/signature"
require "sneakers/application"
require "sneakers/signed_applications"
require "sneakers/verified_payload"
require "sneakers/railtie" if defined?(Rails)
