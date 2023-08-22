# frozen_string_literal: true

module Olivander
  module Components
    class TablePortletComponent < ViewComponent::Base
      renders_one :header_tools
      renders_one :footer_buttons

      def initialize(collection, headers: true, builder:, title: '', background: nil, header_background: 'bg-secondary', turbo_frame: nil, max_height: nil)
        super
        @collection = collection
        @builder = builder
        @title = title
        @background = background
        @header_background = header_background
        @turbo_frame = turbo_frame
        @max_height = max_height
        @headers = headers
      end

      class TableComponent < ViewComponent::Base
        with_collection_parameter :item
        delegate :can?, :cannot?, to: :helpers
        delegate :user_image_path, to: :helpers

        def initialize(item:, item_iteration:, builder:, headers:)
          super
          @item = item
          @item_iteration = item_iteration
          @builder = builder
          @headers = headers
        end
      end

      class Builder
        attr_accessor :field_blocks, :header_tools, :footer_buttons

        def initialize(collection, &block)
          self.field_blocks = []
          block.call(self) if block_given?
        end

        def field(key, alignment = 'text-left', &block)
          unless block_given?
            block = Proc.new{ |x| x.send(key).to_s.html_safe }
          end
          field_blocks << OpenStruct.new(key: key, alignment: alignment, block: block)
        end

        def with_header_tools(&block)
          self.header_tools = block
        end

        def with_footer_buttons(&block)
          self.footer_buttons = block
        end
      end
    end
  end
end
