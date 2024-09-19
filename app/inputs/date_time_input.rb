class DateTimeInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    raw_value = parse_value(object.public_send(attribute_name), options[:date_format])

    disabled = options[:disabled] || false

    hash = { id: "#{attribute_name}_datetimepicker", class: 'form-control datetimepicker-input', value: raw_value, disabled: disabled, 'data-toggle': 'datetimepicker', 'data-target': "##{attribute_name}_datetimepicker" }
    data = options[:data] || {}
    data.keys.each do |d|
      hash["data-#{d.to_s.dasherize}".to_sym] = data[d]
    end
    field = @builder.text_field(attribute_name, hash)

    add_on_class = options[:add_on_class] || "fa fa-calendar"

    add_on = template.content_tag(:div, class: "input-group-prepend") do
      add_on = template.content_tag(:div, class: "input-group-text") do
        hash = { class: add_on_class, 'data-toggle': 'datetimepicker', 'data-target': "##{attribute_name}_datetimepicker" }
        template.content_tag(:i, '', hash)
      end
    end

    all = content_tag(:div, add_on + field, class: 'input-group')

    script = "".html_safe
    unless disabled then
      picker_options = options[:picker_options] || { "format": "MM/DD/YYYY" }

      script = """
        <script>
        $(document).ready(function() {
          $('##{attribute_name}_datetimepicker').datetimepicker(
            #{picker_options.to_json}
          );
        });
        </script>
      """.html_safe
    end

    all + script
  end

  def parse_value(raw_value, format)
    return nil unless raw_value.present?

    format ||=  case raw_value.class.name
                when 'Time', 'ActiveSupport::TimeWithZone'
                  '%m/%d/%Y %H:%M %p'
                else
                  '%m/%d/%Y'
                end
    raw_value.strftime(format)
  end
end
