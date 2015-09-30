$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "dotenv"
Dotenv.load

require "sneakers"
require "sneakers/registered_applications"

module TestHelpers
  module_function def payer_hash
    {
      email: "foo@example.com",
      first_name: "Foo",
      last_name: "Foonly",
      phone: "555-123456",
      # TODO: revisit this, address should be structured, but possibly not MVP
      address: "98 Foo Street, Fooville",
    }
  end

  module_function def tns_funding_hash
    {
      via: "tns",
      session: "SESSION12345678",
    }
  end

  module_function def ten_dollars
    {amount: "1000", currency: "AUD"}
  end

  module_function def zero_dollars
    {amount: "0", currency: "AUD"}
  end

  module_function def supporter_donation_public_key
    ENV.fetch("SUPPORTER_DONATION_PUBLIC_KEY")
  end

  module_function def supporter_donation_secret_key
    ENV.fetch("SUPPORTER_DONATION_SECRET_KEY")
  end
end
