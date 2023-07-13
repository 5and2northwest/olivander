module Olivander
  module Menus
    class MenuItem
      attr_reader :href

      def initialize(key, href = nil, icon = nil, is_module: false)
        @key = key
        @href = href
        @icon = icon
        @submenu_items_blocks = []
        @badges_blocks = []
        @module = is_module
      end

      def module?
        @module
      end

      def text
        resolved_key(@key, "menus.#{@key}.text")
      end

      def icon_class
        @icon || resolved_key(@key, "menus.#{@key}.icon", 'menus.default_icon')
      end

      def visible
        @visible ||= evaluate_conditions_block
      end

      def with_condition(&block)
        @conditions_block = block
        self
      end

      def with_submenu_items(&block)
        @submenu_items_blocks << block
        self
      end

      def submenu_items
        @submenu_items ||= [].tap do |arr|
          if visible
            @submenu_items_blocks.each do |block|
              block.call.each { |item| arr << item if item.visible }
            end
          end
        end
      end

      def with_badges(&block)
        @badges_blocks << block
        self
      end

      def badges
        @badges ||= [].tap do |arr|
          if visible
            @badges_blocks.each do |block|
              block.call.each { |badge| arr << badge }
            end
          end
        end
      end

      private

      def evaluate_conditions_block
        if @conditions_block
          @conditions_block.call
        else
          true
        end
      end

      def resolved_key(raw, key = nil, fallback = nil)
        return nil unless raw

        if key && I18n.exists?(key)
          I18n.t(key)
        elsif fallback && I18n.exists?(fallback)
          I18n.t(fallback)
        else
          raw.titleize
        end
      end
    end

    class Badge
      attr_accessor :text, :badge_class
  
      def initialize(text = nil, badge_class = nil)
        @text = text
        @badge_class = badge_class
      end
  
      def with_proc
        yield(self)
        self
      end
    end
  end
end
