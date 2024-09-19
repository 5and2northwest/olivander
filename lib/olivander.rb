require 'olivander/version'
require 'olivander/engine'
require 'olivander/application_context'
require 'olivander/menus'
require 'pathname'
require 'o18n'

module Olivander
  # Root pathname to get the path of Olivander files like templates or dictionaries
  def self.root
    @root ||= Pathname.new(__dir__).freeze
  end
end
