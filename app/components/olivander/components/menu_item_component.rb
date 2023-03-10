# frozen_string_literal: true

class Olivander::Components::MenuItemComponent < ViewComponent::Base
  attr_reader :menu_item

  def initialize(menu_item)
    super
    @menu_item = menu_item
  end
end
