require "test_helper"
require "generators/olivander/scaffold/scaffold_generator"

module Olivander
  class Olivander::ScaffoldGeneratorTest < Rails::Generators::TestCase
    tests Olivander::ScaffoldGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
