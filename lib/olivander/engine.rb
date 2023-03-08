module Olivander
  class Engine < ::Rails::Engine
    isolate_namespace Olivander

    initializer "olivander.assets.precompile" do |app|
      app.config.assets.precompile += %w( adminlte.js adminlte.css avatar0.png avatar1.png avatar2.png avatar3.png avatar4.png)
    end

    initializer "olivander.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Olivander::ApplicationHelper
      end
    end
  end
end
