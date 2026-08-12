# frozen_string_literal: true

# app/components/tab_component.rb
module Olivander
  module Components
    # component to render tabs
    class TabsComponent < ViewComponent::Base
      renders_many :tabs, '::Olivander::Components::TabsComponent::Tab'

      attr_reader :id, :card, :card_class, :tab_strip_id, :tab_content_id

      def initialize(*args)
        super()
        options = args.extract_options!
        @id = options[:id] || "tabs-#{SecureRandom.hex(4)}"
        @card = options.key?(:card) ? !!options[:card] : true
        @card_class = options.key?(:card_class) ? options[:card_class] : 'card-primary'
        @tab_strip_id = "tab-strip-#{SecureRandom.hex(4)}"
        @tab_content_id = "tab-strip-#{SecureRandom.hex(4)}"
      end

      class Tab < ViewComponent::Base
        attr_reader :title, :id, :active

        def initialize(title:, id: "tab-#{SecureRandom.hex(6)}", active: false)
          super()
          @title = title
          @id = id
          @active = active
        end

        def call
          content
        end
      end
    end
  end
end
