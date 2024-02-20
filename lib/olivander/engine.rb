module Olivander
  class Engine < ::Rails::Engine
    isolate_namespace Olivander

    initializer "olivander.assets.precompile" do |app|
      app.config.assets.precompile += %w[
        adminlte.js datatable_index_charts_controller.js
        datatable_expandable_chart_controller.js
        turbo_flash_controller.js
        modal_controller.js
        lightbox_image_controller.js
        adminlte.css avatar0.png avatar1.png avatar2.png avatar3.png avatar4.png]
    end

    initializer "olivander.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper Olivander::ApplicationHelper
      end
    end

    initializer "olivander.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join('config/importmap.rb')
    end
  end
end
