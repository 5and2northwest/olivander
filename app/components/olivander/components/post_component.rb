# frozen_string_literal: true

module Olivander
  module Components
    class PostComponent < ViewComponent::Base
      renders_one :tools
      delegate :user_image_path, to: :helpers

      def initialize(poster, posted, updated, text: nil, id: nil, avatar_url: nil)
        super
        @poster = poster
        @posted = posted
        @updated = updated
        @text = text
        @id = id
        @avatar_url = avatar_url
      end
    end
  end
end
