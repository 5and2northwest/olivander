module Olivander
  module ApplicationHelper
    def page_title
      cf = content_for(:title)
      return cf unless cf.blank?

      controller_key = controller.class.name.underscore
      key = "page_titles.#{controller_key}.#{action_name}"
      return I18n.t(key) if I18n.exists?(key)

      return @page_title if @page_title

      "#{controller_name}: #{action_name}".titleize
    end

    def user_image_path(user)
      return "avatar#{SecureRandom.random_number(4)}.png" unless user.present? && user.respond_to?(:avatar_path)

      user.avatar_path
    end

    def authorized_resource_actions(route_builder, resource, for_action: :show)
      raw_name = resource.is_a?(Class) ? resource.name : resource.class.name
      plural_name = raw_name.demodulize.underscore.pluralize
      routed_resource = route_builder.resources[plural_name.to_sym]
      return [] if routed_resource.nil?

      actions = resource.is_a?(Class) ?
        (routed_resource.unpersisted_crud_actions | routed_resource.collection_actions.select{ |x| !x.crud_action }) : 
        (resource.persisted? ? (routed_resource.persisted_crud_actions | routed_resource.member_actions.select{ |x| !x.crud_action }): [])
      actions = actions.reject{ |a| a.sym == for_action || !EffectiveDatatables.authorization_method.call(controller, a.sym, resource) }
      preferred = %i[show edit destroy]
      [].tap do |arr|
        preferred.each do |p|
          actions.each do |a|
            arr << a if a.sym == p
          end
        end
        actions.reject{ |x| preferred.include?(x.sym) }.each do |a|
          arr << a
        end
      end
    end

    def resource_form_actions(route_builder, resource, for_action: :show)
      render partial: 'resource_form_actions', locals: { actions: authorized_resource_actions(route_builder, resource, for_action: for_action).select(&:show_in_form) }
    end

    def resource_form_action_label(resource, action)
      key = resource.class.name.underscore
      return I18n.t("activerecord.actions.#{key}.#{action}") if I18n.exists?("activerecord.actions.#{key}.#{action}")
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
      sym_s = sym.to_s.gsub('.', '_')
      i18n_key = "activerecord.attributes.#{resource_class.name.underscore}.#{sym_s}"
      return I18n.t(i18n_key) if I18n.exists?(i18n_key)

      sym.to_s.titleize
    end

    def is_dev_environment?
      sidebar_context_suffix != 'production'
    end

    def sidebar_context_name
      [@context.name, sidebar_context_suffix&.upcase].reject{ |x| x.blank? or x == 'PRODUCTION' }.join(' ')
    end

    def sidebar_context_suffix
      suffix = nil
      suffix ||= ENV['CLIENT_ENVIRONMENT']
      parts = request.host.split('.')
      suffix ||= parts.first.split('-').last.downcase if request.host.include?('-')
      suffix ||= 'local' if %w[localhost test].include?(parts.last.downcase)
      suffix ||= 'production'
      suffix
    end

    def sidebar_background_class
      @context.sidebar_background_class ||
        ENV['SIDEBAR_BACKGROUND_CLASS'] ||
        (is_dev_environment? ? 'bg-danger' : 'bg-info')
    end

    def header_page_title
      [is_dev_environment? ? sidebar_context_suffix.upcase : nil, page_title].reject(&:blank?).join(' ')
    end

    def favicon_link
      favicon_path = is_dev_environment? ? '/images/favicon-dev.png' : '/images/favicon.ico'
      favicon_link_tag(image_path(favicon_path))
    end

    def flash_class key
      case key
      when "error"
        "danger"
      when "notice"
        "info"
      when "alert"
        "danger"
      else
        key
      end
    end

    def flash_icon key
      case key
      when "error"
        "fas fa-exclamation-circle"
      when "notice"
        "fas fa-info-circle"
      when "alert"
        "fas fa-info-circle"
      when "success"
        "fas fa-check-circle"
      else
        "fas fa-question-circle"
      end
    end

    def collection_component_builder_for(klass, collection, *args, &block)
      builder = klass::Builder.new(self, &block)
      options = args.extract_options!
      options[:builder] = builder
      render klass.new(collection, *(args + [options])) do |component|
        if builder.header_tools.present?
          component.with_header_tools do
            builder.header_tools.call
          end
        end
        if builder.footer_buttons.present?
          component.with_footer_buttons do
            builder.footer_buttons.call
          end
        end
      end 
    end
  end
end
