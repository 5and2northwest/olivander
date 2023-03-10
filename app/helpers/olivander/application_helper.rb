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
  end
end
