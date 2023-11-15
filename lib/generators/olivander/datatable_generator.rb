module Olivander
  class DatatableGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

    source_root File.expand_path('datatable/templates', __dir__)

    def create_datatable
      template "datatable.rb", File.join("app/datatables", controller_file_path, "../#{file_name}_datatable.rb")
    end
  end
end
