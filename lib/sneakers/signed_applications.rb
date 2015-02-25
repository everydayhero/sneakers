module Sneakers
  module SignedApplications
    @applications = {}

    module_function def fetch(name)
      @applications.fetch(name)
    end

    module_function def register(*args)
      application = Application.new(*args)

      @applications[application.name] = application
    end

    module_function def deregister(name)
      @applications.delete(name)
    end
  end
end
