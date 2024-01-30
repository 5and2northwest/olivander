module Olivander
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.audited_as klazz
      # Rails.logger.debug "#{self.class.name} is audited as #{klazz.name}"
      @@audited_user_class = klazz

      belongs_to :created_by, class_name: klazz.name
      belongs_to :updated_by, class_name: klazz.name

      before_validation :set_audit_user
    end

    def set_audit_user
      self.created_by ||= @@audited_user_class.current
      self.updated_by = @@audited_user_class.current
    end
  end
end
