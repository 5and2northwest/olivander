# frozen_string_literal: true

# extension of I18n
class O18n
  ENV_REGEX = /\$ENV\{(\w*)\}/.freeze

  def self.t(*args, **kwargs)
    value = I18n.t(*args, **kwargs)
    value.gsub(ENV_REGEX) do
      envar = ENV[Regexp.last_match(1)]
      if envar.blank?
        Regexp.last_match(1).titleize
      else
        I18n.exists?(envar) ? I18n.t(envar) : envar
      end
    end
  end
end
