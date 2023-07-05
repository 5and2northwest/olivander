module Olivander
  module Resources
    module AutoFormAttributes
      extend ActiveSupport::Concern

      included do
        def auto_form_attributes
          attributes.keys - ['updated_at', 'created_at', 'deleted_at']
        end
      end
    end
  end
end
