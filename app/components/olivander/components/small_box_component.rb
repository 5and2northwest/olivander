# frozen_string_literal: true

module Olivander
  module Components
    class SmallBoxComponent < ViewComponent::Base
      def initialize(
        background: 'bg-danger',
        primary_text: 'Loading...',
        secondary_text: "&nbsp;".html_safe,
        icon: 'fas fa-sync-alt fa-spin',
        more_link: nil,
        more_text: '',
        more_icon: 'fas fa-arrow-circle-right',
        turbo_frame: nil,
        loading: true,
        src: nil,
        overlay: 'dark'
        )
        super
        @background = background
        @primary_text = primary_text
        @secondary_text = secondary_text
        @icon = icon
        @more_link = more_link
        @more_text = more_text
        @more_icon = more_icon
        @turbo_frame = turbo_frame
        @loading = loading
        @src = src
        @overlay = overlay
      end
    end
  end
end
