require "rails/generators/active_record/model/model_generator"

module Olivander
  class ActiveRecordGenerator < ActiveRecord::Generators::ModelGenerator
    desc  "This will generate ActiveRecord files using Olivander templates"
    argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

    # redefine the source path so we can isolate our templates
    # note that ActiveRecords's generator defines a path like:
    # ../../migration/templates/create_table_migration.rb
    # so we have to put two dummy path positions to counter-act
    # the ../.. and of course append .tt for thor to treat the file
    # as a template
    source_root File.expand_path('active_record/model/templates', __dir__)

    def create_migration_file
      self.attributes = shell.base.attributes
      super
    end
  end
end
