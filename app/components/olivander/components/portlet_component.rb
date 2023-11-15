# frozen_string_literal: true

module Olivander
  module Components
    class PortletComponent < ViewComponent::Base

      renders_one :header_tools

      def initialize(title, *args)
        super
        @title = title
        options = args.extract_options!
        @card_type = options[:card_type] || 'card-default'
        @background = options[:background]
        @header_background = options[:header_background]
        @turbo_frame = options[:turbo_frame]
        @src = options[:src]
        @loading = options[:loading]
        @card_data = options[:card_data]
        @turbo_frame_data = options[:turbo_frame_data]
      end
    end
  end
end
