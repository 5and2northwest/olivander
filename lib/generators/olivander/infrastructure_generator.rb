module Olivander
  class InfrastructureGenerator < Rails::Generators::Base
    source_root File.expand_path('templates/infrastructure', __dir__)

    # boolean option — use --no-application-controller to disable
    class_option :application_controller,
                 type: :boolean,
                 default: true,
                 desc: "Modify ApplicationController to include infrastructure hooks"

    def create_infrastructure
      create_builders
      setup_asset_pipeline
      modify_application_controller
      create_hello_olivander
      route 'root "hello_olivander#index"'
    end
  
    private
    
    def create_builders
      template "route_builder.rb", File.join("app/services", "route_builder.rb")
      template "context_builder.rb", File.join("app/services", "context_builder.rb")
      template "menu_builder.rb", File.join("app/services", "menu_builder.rb")
    end
    
    def setup_asset_pipeline
      template "manifest.js", File.join("app/assets/config", "manifest.js")
      pin_all = 'pin_all_from "#{Olivander.root}/../app/assets/javascripts/controllers", under: "controllers"'
      inject_into_file 'config/importmap.rb', pin_all, verbose: true, force: false
    end

    def create_hello_olivander
      template "hello_olivander_controller.rb", File.join("app/controllers", "hello_olivander_controller.rb")
    end
  
    # Insert a safe snippet into ApplicationController
    def modify_application_controller
      unless options[:application_controller]
        say_status :skip, "ApplicationController modification skipped", :yellow
        return
      end
  
      target = File.join("app", "controllers", "application_controller.rb")
      snippet = <<~RUBY
  
        # --- Olivander infrastructure additions (generated) ---
        # If you want to remove this, delete the lines between the markers.
        before_action :build_context
    
        def build_context
          # can?(:build, :context)
          ContextBuilder.build_context
        end

        def authorize!(*args)
          # implement authorization logic
        end
        # ------------------------------------------------------
      RUBY
  
      if File.exist?(target)
        inject_into_class target, "ApplicationController", snippet.indent(2)
        say_status :insert, "added infrastructure hooks to #{target}", :green
      else
        # create a minimal ApplicationController if none exists
        create_file target, <<~RUBY
          class ApplicationController < ActionController::Base
            #{snippet.indent(2)}
          end
        RUBY
        say_status :create, "#{target} (new)", :green
      end
    end
  end  
end
