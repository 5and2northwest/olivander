# frozen_string_literal: true

# extension of I18n
class O18n
  ENV_REGEX = /\$ENV\{(\w*)\}/.freeze

  def self.t(*args, **kwargs)
    value = I18n.t(*args, **kwargs)
    value.gsub(ENV_REGEX) {
      envar = ENV[$1]
      unless envar.blank?
        I18n.exists?(envar) ? I18n.t(envar) : envar
      else
        $1.titleize
      end
    }
  end
end
