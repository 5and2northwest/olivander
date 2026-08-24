module Olivander
  module Resources
    module AutoFormAttributes
      extend ActiveSupport::Concern

      included do
        def auto_form_attributes
          attributes.keys - %w[updated_at created_at deleted_at]
        end

        def self.method_missing(m, *args, **kwargs, &block)
          if %i[auto_resource_fields resource_field_groups resource_field_group].include?(m)
            include(Olivander::Resources::ResourceFields)
            send(m, *args, **kwargs, &block)
          else
            super
          end
        end

        def self.tracked_attrs
          @tracked_attrs ||= { readers: [], writers: [], accessors: [] }
        end

        # when subclassing, make sure the subclass gets a copy of parent's tracked attrs
        def self.inherited(subclass)
          super if defined?(super)

          # copy parent's lists into subclass so they are independent arrays
          tracked_attrs.each do |key, arr|
            subclass.tracked_attrs[key].concat(arr.dup)
          end
        end

        # override attr_* to capture names, then delegate to the original behavior
        def self.attr_reader(*names)
          tracked_attrs[:readers].concat(names.map(&:to_sym))
          super
        end

        def self.attr_writer(*names)
          tracked_attrs[:writers].concat(names.map(&:to_sym))
          super
        end

        def self.attr_accessor(*names)
          tracked_attrs[:accessors].concat(names.map(&:to_sym))
          super
        end

        # accessors for the tracked data (unique and preserved order)
        def self.tracked_attrs
          @tracked_attrs ||= { readers: [], writers: [], accessors: [] }
        end

        def self.readers
          tracked_attrs[:readers].uniq
        end

        def self.writers
          tracked_attrs[:writers].uniq
        end

        def self.accessors
          tracked_attrs[:accessors].uniq
        end

        def self.all_tracked_attributes
          (readers + writers + accessors).uniq
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
          auto_resource_fields if resource_field_group_collection.nil?
          resource_field_group_collection
        end

        def self.auto_resource_fields(columns: 2, only: [], except: [], editable: true, on_show: true, on_form: true)
          return unless ActiveRecord::Base.connection.table_exists?(table_name)

          if current_resource_field_group.nil?
            resource_field_group(editable: editable, on_show: on_show, on_form: on_form) do
              auto_resource_fields(columns: columns, only: only, except: except, editable: editable, on_show: on_show,
                                   on_form: on_form)
            end
          elsif current_resource_field_group.forced_section.nil?
            resource_field_section(columns) do
              auto_resource_fields(columns: columns, only: only, except: except, editable: editable, on_show: on_show,
                                   on_form: on_form)
            end
          else
            if only.size.zero?
              only = [
                self.columns.collect { |x| x.name.to_sym },
                reflections.map { |r| r[1].name }
              ]
              only << attachment_definitions.select { |x| x[0] } if respond_to?(:attachment_definitions)
              only = only.flatten - SKIPPED_ATTRIBUTES
            end
            only -= except
            only.each do |inc|
              all_tracked_attributes.each do |sym|
                next unless inc == sym

                resource_field sym, :string, editable: false, on_show: true, on_form: false
              end

              self.columns.each do |att|
                sym = att.name.to_sym
                type = att.type
                next unless inc == sym

                resource_field sym, type, editable: editable, on_show: on_show, on_form: on_form
              end

              reflections.map { |x| x[1] }
                         .filter { |x| x.foreign_key == inc || x.name == inc }
                         .each do |r|
                type = r.association_class.name.demodulize.underscore.to_sym
                resource_field(r.name, type, editable: editable && !uneditable_association?(r, type))
              rescue NotImplementedError
                resource_field(r.name, :association, editable: editable && !uneditable_association?(r, type))
              end

              next unless respond_to?(:attachment_definitions)

              attachment_definitions.filter { |x| x == inc }.each do |ad|
                resource_field ad[0], :file, editable: editable
              end
            end
          end
        end

        def self.uneditable_association?(r, type)
          return false unless r.options.keys.include?(:through)

          # this collection may prove to be larger than one...
          %i[has_one_through_association].include?(type)
        end

        def self.resource_field_group(key = :default, editable: true, on_show: true, on_form: true)
          self.resource_field_group_collection ||= []
          self.current_resource_field_group = resource_field_group_collection.select { |x| x.key == key }.first
          unless current_resource_field_group.present?
            self.current_resource_field_group = ResourceFieldGroup.new(key, editable, on_show, on_form)
            self.resource_field_group_collection << current_resource_field_group
          end
          yield
          self.current_resource_field_group = nil
        end

        def self.resource_field_section(columns = nil)
          current_resource_field_group.forced_section = current_resource_field_group.next_section(columns)
          yield
          current_resource_field_group.forced_section = nil
        end

        def self.resource_field(sym, type = :string, editable: nil, on_show: true, on_form: true)
          current_resource_field_group.add_field(sym, type, editable, on_show, on_form)
        end
      end

      class ResourceFieldGroup
        attr_accessor :fields, :key, :editable, :forced_section, :sections, :on_show, :on_form

        def initialize(key, editable, on_show, on_form)
          self.key = key
          self.editable = editable
          self.on_show = on_show
          self.on_form = on_form
          self.fields = []
          self.sections = []
        end

        def add_field(sym, type, editable, on_show, on_form)
          e = editable.nil? ? self.editable : editable
          s = on_show
          f = on_form
          section = forced_section || next_section
          field = ResourceField.new(sym, type, e, s, f, self)
          section.fields << field
          fields << field
        end

        def next_section(columns = 1)
          section = ResourceFieldSection.new(columns)
          sections << section
          section
        end

        def max_section_columns
          sections.collect { |x| x.columns }.max
        end
      end

      class ResourceFieldSection
        attr_accessor :fields, :columns

        def initialize(columns = 1)
          self.columns = columns
          self.fields = []
        end

        def column_class
          "col-md-#{12 / columns}"
        end

        def show_fields
          fields.select { |f| f.on_show }
        end

        def form_fields
          fields.select { |f| f.on_form }
        end
      end

      class ResourceField
        attr_accessor :sym, :type, :editable, :on_show, :on_form

        def initialize(sym, type, editable, on_show, on_form, _group)
          self.sym = sym
          self.type = type
          self.on_show = on_show
          self.on_form = on_form
          self.editable = editable
        end
      end
    end
  end
end
