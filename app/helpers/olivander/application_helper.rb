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

    def authorized_resource_actions(resource, for_action: :show)
      plural_name = resource.is_a?(Class) ? resource.table_name : resource.class.table_name
      routed_resource = @context.route_builder.resources[plural_name.to_sym]
      actions = resource.is_a?(Class) ?
        (routed_resource.unpersisted_crud_actions | routed_resource.collection_actions) : 
        (resource.persisted? ? (routed_resource.persisted_crud_actions | routed_resource.member_actions): [])
      actions.reject{ |a| a.sym == for_action }
    end

    def resource_form_actions(resource, for_action: :show)
      [].tap do |output|
        authorized_resource_actions(resource, for_action: for_action).select{ |x| x.show_in_form }.each do |a|
          output << link_to(a.sym, {controller: a.controller, action: a.action}, method: a.verb, class: 'btn btn-primary', data: { turbo: true })
        end
      end.join('&nbsp;').html_safe
    end
  end
end
