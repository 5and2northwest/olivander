# frozen_string_literal: true

class Olivander::Components::ResourceFormComponent < ViewComponent::Base
  delegate :resource_field_group_label, to: :helpers

  def initialize(resource, form_builder)
    @resource = resource
    @f = form_builder
    super
  end

  def collection_for(field)
    @f.object.send(field.sym)
  end

  def association_data_hash_for(field)
    {
      collection_path: collection_path_for(field),
      controller: "association-#{@resource.class.name.underscore.dasherize.gsub('/', '-')}-#{field.sym} input-control-association",
      taggable: taggable?(field),
      tag_field_name: tag_field_name(field)
    }
  end

  def input_data_hash_for(field)
    {
      controller: "input-#{@resource.class.name.underscore.dasherize.gsub('/', '-')}-#{field.sym} input-control-#{field.type}",
    }
  end

  def taggable?(field)
    method_key = "#{field.sym}_taggable?"
    return false unless @resource.class.respond_to?(method_key)

    @resource.class.send(method_key)
  end

  def tag_field_name(field)
    return '' unless taggable?(field)

    @resource.class.send("#{field.sym}_tag_field_name")
  end

  def collection_path_for(field)
    begin
      polymorphic_path(@resource.class.reflect_on_association(field.sym).klass, format: :json)
    rescue
      ''
    end
  end

  def association?(field)
    %i[
      association belongs_to_association has_many_association has_many_through_association has_and_belongs_to_many_reflection has_one_through_association
    ].include?(field.type)
  end

  def one_through?(field)
    field.type == :has_one_through_association
  end

  def boolean?(field)
    field.type == :boolean
  end
end
