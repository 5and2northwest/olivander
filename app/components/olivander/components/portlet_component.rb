# frozen_string_literal: true

module Olivander
  module Components
    class PortletComponent < ViewComponent::Base
      def initialize(title, background: nil, header_background: 'bg-info', turbo_frame: nil, src: nil, loading: nil)
        super
        @title = title
        @background = background
        @header_background = header_background
        @turbo_frame = turbo_frame
        @src = src
        @loading = loading
      end
    end
  end
end
