require 'rails/generators/rails/controller/controller_generator'

module Olivander
  class ControllerGenerator < Rails::Generators::ControllerGenerator
    source_root File.expand_path('controller/templates', __dir__)
  end
end
