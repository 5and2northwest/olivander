# frozen_string_literal: true

class Olivander::Components::ResourceFormComponent < ViewComponent::Base
  delegate :resource_field_group_label, to: :helpers
  delegate :field_label_for, to: :helpers

  def initialize(resource, form_builder)
    @resource = resource
    @f = form_builder
    super
  end

  def collection_for(field)
    @f.object.send(field.sym)
  end

  def label_data_hash_for(field)
    help_text_key = ['activerecord.attributes', @resource.class.name.underscore, "#{field.sym}_help_text"].join('.')
    {}.tap do |hash|
      hash[:popper_text] = O18n.t(help_text_key) if I18n.exists?(help_text_key)
    end
  end

  def association_data_hash_for(field)
    {
      collection_path: collection_path_for(field),
      controller: "association-#{@resource.class.name.underscore.dasherize.gsub('/',
                                                                                '-')}-#{field.sym} input-control-association",
      taggable: taggable?(field),
      tag_field_name: tag_field_name(field)
    }.merge(label_data_hash_for(field))
  end

  def input_data_hash_for(field)
    {
      controller: "input-#{@resource.class.name.underscore.dasherize.gsub('/',
                                                                          '-')}-#{field.sym} input-control-#{field.type}"
    }.merge(label_data_hash_for(field))
  end

  def input_picker_options_for(field)
    case field.type
    when :datetime
      { icons: { time: 'far fa-clock' } }
    when :date
      { 'format': 'MM/DD/YYYY' }
    else
      {}
    end
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
    polymorphic_path(@resource.class.reflect_on_association(field.sym).klass, format: :json)
  rescue StandardError
    ''
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
