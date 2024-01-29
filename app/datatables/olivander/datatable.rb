module Olivander
  class Datatable < Effective::Datatable
    def link_col(field, path, path_args, visible: true)
      dsl_tool.col(field, visible: visible) do |r|
        args = [].tap do |arr|
          if path_args.is_a? Array
            path_args.each do |arg|
              arr << r.send(arg)
            end
          else
            arr << r.send(path_args)
          end
        end
        link_to r.send(field), send(path, args)
      end
    end

    def self.auto_datatable(klazz, collection: nil, link_path: nil, only: [], except: [], hide: [], show: [], order_by: [], scopes: [])
      Rails.logger.debug "initializing datatable for #{klazz}"

      instance = klazz.new
      klazz_attributes = instance.attributes.collect{ |x| x[0] }
      column_attributes = klazz_attributes
      column_attributes &&= only if only.size.positive?
      column_attributes -= except if except.size.positive?
      resources_sym = klazz.table_name.to_sym
      bulk_action_list = self::ROUTE_BUILDER.resources[resources_sym]&.datatable_bulk_actions || []

      default_hidden = %w[
        id created updated created_at updated_at
        deleted_at current_user current_action
        application_tenant_id created_by_id updated_by_id
      ]

      filters do
        scopes.each do |s|
          scope s
        end
      end

      collection do
        dc = collection.nil? ? klazz.all : collection

        attributes.each do |att|
          dc = dc.where("#{att[0]} = ?", att[1]) if klazz_attributes.include?(att[0].to_s)
        end

        dc
      end

      if bulk_action_list.size.positive?
        bulk_actions do
          bulk_action_list.each do |ma|
            if ma.confirm
              bulk_action ma.sym, url_for(controller: ma.controller, action: "confirm_#{ma.action}")
            else
              bulk_action ma.sym, send(ma.path_helper), data: { turbo_frame: ma.turbo_frame }
            end
          end
        end
      end

      datatable do
        order(order_by[0], order_by[1]) if order_by.size == 2
        Rails.logger.debug "bulk actions size: #{datatable._bulk_actions.size}"
        Rails.logger.debug "bulk actions size: #{datatable._bulk_actions.size.positive?}"
        # bulk_actions_col if datatable._bulk_actions.size.positive?

        #TODO: use columns from model here instead of attributes keys
        column_attributes.each do |key|
          label = field_label_for(klazz, key)
          sym = key.gsub('_id', '')
          visible = show.include?(key) || !(default_hidden.include?(key) || hide.include?(key))
          if %w[id name first_name last_name display_name title].include?(sym)
            col sym, visible: visible, action: :show
          elsif sym.include?('.')
            col sym, visible: visible, label: label
          elsif klazz.columns.select{ |x| x.name == key }.first&.type == :boolean
            col sym, visible: visible, label: label do |c|
              val = c.send(sym)
              icon_class = val ? 'fa-check text-success' : 'fa-times text-danger'
              "<div class='text-center'><i class='fa fa-icon #{icon_class}'></div>".html_safe
            end
          else
            col sym, visible: visible, label: label
          end
        end
        actions_col
      end
    end
  end
end
