module Olivander
  class ScaffoldGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

    source_root File.expand_path('templates/scaffold', __dir__)

    hook_for :orm, as: :model, required: true do |instance, controller|
      instance.invoke controller, [ instance.name ], instance.options.merge({ test_framework: false })
    end

    hook_for :datatable, as: :boolean, default: true

    hook_for :resource_controller do |instance, controller|
      instance.invoke controller, [ instance.name.pluralize ], instance.options.merge({ helper: false, test_framework: false, assets: false })
    end

    def create_views
      # template "views/_form.html.haml", File.join("app/views", controller_file_path, '_form.html.haml')
      # template "views/_model.html.haml", File.join("app/views", controller_file_path, "_#{file_name}.html.haml")
    end

    hook_for :resource_route, in: :rails
  end
end
