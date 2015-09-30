module Sneakers
  module SignedApplications
    @applications = {}

    module_function def fetch(public_key)
      @applications.fetch(public_key)
    end

    module_function def register(*args)
      application = Application.new(*args)

      @applications[application.public_key] = application
    end
  end
end
