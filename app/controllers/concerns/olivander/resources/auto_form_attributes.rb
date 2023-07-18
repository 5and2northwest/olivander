module Olivander
  module Resources
    module AutoFormAttributes
      extend ActiveSupport::Concern

      included do
        def auto_form_attributes
          attributes.keys - ['updated_at', 'created_at', 'deleted_at']
        end

        def self.method_missing(m, *args, &block)
          if %i[auto_resource_fields resource_field_groups resource_field_group].include?(m)
            include(Olivander::Resources::ResourceFields)
            send(m, *args, &block)
          else
            super
          end
        end
      end
    end

    module ResourceFields
      extend ActiveSupport::Concern
      SKIPPED_ATTRIBUTES = %i[id created_at updated_at deleted_at]

      included do
        cattr_accessor :current_resource_field_group
        cattr_accessor :current_resource_field_row
        cattr_accessor :resource_field_group_collection

        def self.resource_field_groups
          auto_resource_fields if self.resource_field_group_collection.nil?
          self.resource_field_group_collection
        end

        def self.auto_resource_fields(columns: 2, only: [])
          if current_resource_field_group.nil?
            resource_field_group do
              auto_resource_fields(columns: columns, only: only)
            end
          elsif current_resource_field_group.forced_section.nil?
            resource_field_section(columns) do
              auto_resource_fields(columns: columns, only: only)
            end
          else
            only = self.columns.collect{ |x| x.name.to_sym } - SKIPPED_ATTRIBUTES if only.size.zero?
            self.columns.each do |att|
              sym = att.name.to_sym
              type = att.type
              next unless only.include?(sym)

              reflections.map{ |x| x[1] }
                          .filter{ |x| x.foreign_key == att.name }
                          .each do |r|
                sym = r.name
                type = :association
              end

              resource_field sym, type
            end
          end
        end

        def self.resource_field_group(key = :default, editable: true, &block)
          self.resource_field_group_collection ||= []
          self.current_resource_field_group = resource_field_group_collection.select{ |x| x.key == key}.first
          unless current_resource_field_group.present?
            self.current_resource_field_group = ResourceFieldGroup.new(key, editable)
            self.resource_field_group_collection << self.current_resource_field_group
          end
          yield
          self.current_resource_field_group = nil
        end

        def self.resource_field_section(columns = nil, &block)
          self.current_resource_field_group.forced_section = self.current_resource_field_group.next_section(columns)
          yield
          self.current_resource_field_group.forced_section = nil
        end

        def self.resource_field(sym, type = :string, editable: nil)
          self.current_resource_field_group.add_field(sym, type, editable)
        end
      end

      class ResourceFieldGroup
        attr_accessor :fields, :key, :editable, :forced_section, :sections

        def initialize(key, editable)
          self.key = key
          self.editable = editable
          self.fields = []
          self.sections = []
        end

        def add_field(sym, type, editable)
          e = editable.nil? ? self.editable : editable
          section = forced_section || next_section
          field = ResourceField.new(sym, type, e, self)
          section.fields << field
          fields << field
        end

        def next_section(columns = 1)
          section = ResourceFieldSection.new(columns)
          sections << section
          section
        end

        def max_section_columns
          sections.collect{ |x| x.columns }.max
        end
      end

      class ResourceFieldSection
        attr_accessor :fields, :columns

        def initialize(columns = 1)
          self.columns = columns
          self.fields = []
        end

        def column_class
          "col-md-#{12/columns}"
        end
      end

      class ResourceField
        attr_accessor :sym, :type, :editable

        def initialize(sym, type, editable, group)
          self.sym = sym
          self.type = type
          self.editable = editable
        end
      end
    end
  end
end
