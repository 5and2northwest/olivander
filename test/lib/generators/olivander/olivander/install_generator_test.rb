require "test_helper"
require "generators/olivander/install/install_generator"

module Olivander
  class Olivander::InstallGeneratorTest < Rails::Generators::TestCase
    tests Olivander::InstallGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
