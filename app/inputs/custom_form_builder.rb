class CustomFormBuilder < SimpleForm::FormBuilder
  def initialize(*)
    super
  end

  def association(association, options = {}, &block)
    resolve_custom_input_association(association, options)
    super(association, options, &block)
  end

  def resolve_custom_input_association(association, options)
    return if options[:as].present?

    [
      "#{object.class.name.demodulize.underscore}_#{association.to_s}".to_sym, association
    ].each do |key|
      camelized = "#{key.to_s.camelize}Input"
      mapping = attempt_mapping_with_custom_namespace(camelized) ||
                attempt_mapping(camelized, Object) ||
                attempt_mapping(camelized, self.class)

      next unless mapping.present?

      options[:as] = key
      break
    end
  end

  private

  def fetch_association_collection(reflection, options)
    options_method = "options_for_#{reflection.name}".to_sym
    if object.respond_to?(options_method) then
      options.fetch(:collection) do
        object.send(options_method)
      end
    else
      super(reflection, options)
    end
  end
end