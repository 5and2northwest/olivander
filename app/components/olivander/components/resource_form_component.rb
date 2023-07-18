# frozen_string_literal: true

class Olivander::Components::ResourceFormComponent < ViewComponent::Base
  delegate :resource_field_group_label, to: :helpers

  def initialize(resource, form_builder)
    @resource = resource
    @f = form_builder
    super
  end
end
