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

    def self.auto_datatable(klazz, collection: nil, link_path: nil, only: [], except: [], hide: [], show: [], order_by: [])
      Rails.logger.debug "initializing datatable for #{klazz}"

      klazz_attributes = klazz.new.attributes.collect{ |x| x[0] }
      column_attributes = klazz_attributes
      column_attributes &&= only if only.size.positive?
      column_attributes -= except if except.size.positive?
      resources_sym = klazz.table_name.to_sym
      bulk_action_list = self::ROUTE_BUILDER.resources[resources_sym]&.datatable_bulk_actions || []

      default_hidden = %w[id created updated created_at updated_at deleted_at current_user current_action]

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
              bulk_action ma.sym, url_for(controller: ma.controller, action: ma.action), data: { turbo_frame: ma.turbo_frame }
            end
          end
        end
      end

      datatable do
        order(order_by[0], order_by[1]) if order_by.size == 2
        Rails.logger.debug "bulk actions size: #{datatable._bulk_actions.size}"
        Rails.logger.debug "bulk actions size: #{datatable._bulk_actions.size.positive?}"
        # bulk_actions_col if datatable._bulk_actions.size.positive?
        column_attributes.each do |key|
          label = field_label_for(klazz, key)
          sym = key.gsub('_id', '')
          visible = show.include?(key) || !(default_hidden.include?(key) || hide.include?(key))
          if link_path.present? && sym == :id
            link_col sym, link_path, 'id', visible: visible
          elsif link_path.present? && sym == 'name'
            link_col sym, link_path, :id, visible: visible
          elsif sym.include?('.')
            col sym, visible: visible, label: label
          else
            col sym, visible: visible, label: label
          end
        end
        actions_col
      end
    end
  end
end
