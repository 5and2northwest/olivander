require 'colorized_string'

class ColorKeyValue < Lograge::Formatters::KeyValue
  FIELDS_COLORS = {
    method:     :white,
    path:       :white,
    format:     :red,
    controller: :green,
    action:     :green,
    status:     :yellow,
    duration:   :magenta,
    view:       :magenta,
    db:         :magenta,
    time:       :cyan,
    ip:         :red,
    host:       :red,
    params:     :green,
    unpermitted_params: {color: :black, background: :red},
  }

  def format(key, value)
    line = super(key, value)

    color = FIELDS_COLORS[key] || :default
    ColorizedString[line].colorize(color)
  end
end

Rails.application.configure do
  config.lograge.enabled   = true
  config.lograge.formatter = ColorKeyValue.new
end
