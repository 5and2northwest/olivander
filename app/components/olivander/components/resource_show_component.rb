# frozen_string_literal: true

class Olivander::Components::ResourceShowComponent < ViewComponent::Base
  delegate :field_label_for, to: :helpers
  delegate :resource_field_group_label, to: :helpers

  def initialize(resource, actions)
    super()
    @resource = resource
    @actions = actions
  end
end
