module Sneakers
  module SignedApplications
    @applications = {}

    module_function def fetch(name)
      require "sneakers/registered_applications"
      @applications.fetch(name)
    end

    module_function def register(*args)
      application = Application.new(*args)

      @applications[application.name] = application
    end
  end
end
