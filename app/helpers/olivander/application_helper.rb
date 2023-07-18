module Olivander
  module ApplicationHelper
    def page_title
      return @page_title if @page_title

      cf = content_for(:title)
      return cf unless cf.blank?

      controller_key = controller.class.name.underscore
      key = "page_titles.#{controller_key}.#{action_name}"
      return I18n.t(key) if I18n.exists?(key)

      "#{controller_name}: #{action_name}".titleize
    end

    def user_image_path(user)
      "avatar#{SecureRandom.random_number(4)}.png"
    end

    def authorized_resource_actions(route_builder, resource, for_action: :show)
      raw_name = resource.is_a?(Class) ? resource.name : resource.class.name
      plural_name = raw_name.demodulize.underscore.pluralize
      routed_resource = route_builder.resources[plural_name.to_sym]
      return [] if routed_resource.nil?

      actions = resource.is_a?(Class) ?
        (routed_resource.unpersisted_crud_actions | routed_resource.collection_actions.select{ |x| !x.crud_action }) : 
        (resource.persisted? ? (routed_resource.persisted_crud_actions | routed_resource.member_actions.select{ |x| !x.crud_action }): [])
      actions = actions.reject{ |a| a.sym == for_action || EffectiveDatatables.authorization_method.call(controller, resource, a.sym) }
      preferred = %i[show edit destroy]
      [].tap do |arr|
        preferred.each do |p|
          actions.each do |a|
            arr << a if a.sym == p
          end
        end
        arr &&= actions.reject{ |x| preferred.include?(x.sym) }
      end
    end

    def resource_form_actions(route_builder, resource, for_action: :show)
      render partial: 'resource_form_actions', locals: { actions: authorized_resource_actions(route_builder, resource, for_action: for_action).select(&:show_in_form) }
    end

    def resource_form_action_label(resource, action)
      return I18n.t("activerecord.actions.#{resource}.#{action}") if I18n.exists?("activerecord.actions.#{resource}.#{action}")
      return I18n.t("activerecord.actions.#{action}") if I18n.exists?("activerecord.actions.#{action}")

      action.to_s.titleize
    end

    def resource_field_group_label(resource_class, key)
      i18n_key = "activerecord.attributes.#{resource_class.name.underscore}.resource_field_groups.#{key}"
      I18n.exists?(i18n_key) ? I18n.t(i18n_key) : key.to_s.titleize
    end

    def current_user
      controller.respond_to?(:current_user) ? controller.current_user : nil
    end

    def current_ability
      controller.respond_to?(:current_ability) ? controller.current_ability : nil
    end

    def resource_attributes(resource, effective_resource)
      er_attributes = effective_resource&.model_attributes&.collect{ |x| x[0] }
      return er_attributes if er_attributes.present? && er_attributes.size.positive?

      resource.auto_form_attributes
    end

    def render_optional_partial partial
      begin
        render partial: partial
      rescue ActionView::MissingTemplate
        Rails.logger.debug "did not find partial: #{partial}"
        nil
      end
    end

    def field_label_for(resource_class, sym)
      i18n_key = "activerecord.attributes.#{resource_class.name.underscore}.#{sym}"
      return I18n.t(i18n_key) if I18n.exists?(i18n_key)

      sym.to_s.titleize
    end
  end
end
