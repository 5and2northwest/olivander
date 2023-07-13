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
      actions.reject{ |a| a.sym == for_action }
    end

    def resource_form_actions(route_builder, resource, for_action: :show)
      [].tap do |output|
        authorized_resource_actions(route_builder, resource, for_action: for_action).select{ |x| x.show_in_form }.each do |a|
          output << link_to(a.sym, {controller: a.controller, action: a.action}, method: a.verb, class: 'btn btn-tool', data: { turbo: true })
        end
      end.join('&nbsp;').html_safe
    end

    def current_user
      controller.respond_to?(:current_user) ? controller.current_user : nil
    end

    def current_ability
      controller.respond_to?(:current_ability) ? controller.current_ability : nil
    end
  end
end
