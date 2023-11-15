module Olivander
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def effective_datatables
      template 'effective_datatables.rb', 'config/initializers/effective_datatables.rb'
      template 'effective_resources.rb',  'config/initializers/effective_resources.rb'
    end

    def lograge
      template 'lograge.rb',  'config/initializers/lograge.rb'
    end

    def olivander_base_classes
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
        "  include ::Olivander::ApplicationController\n"
      end
      inject_into_class "app/models/application_record.rb", "ApplicationRecord" do
        "  include ::Olivander::ApplicationRecord\n"
      end
      template 'logo.png',  'public/images/logo.png'
      template 'favicon.ico',  'public/images/favicon.ico'
      template 'favicon-dev.ico',  'public/images/favicon-dev.ico'
      template 'route_builder.rb',  'app/services/route_builder.rb'
      template 'context_builder.rb',  'app_services/context_builder.rb'
    end
  end
end
