module Olivander
  module ApplicationHelper
    def page_title
      'foo'
    end

    def user_image_path(user)
      "avatar#{SecureRandom.random_number(4)}.png"
    end
  end
end
