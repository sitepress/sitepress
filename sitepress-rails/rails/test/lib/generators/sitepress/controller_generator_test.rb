require "test_helper"
require "generators/sitepress/controller/controller_generator"

class Sitepress::ControllerGeneratorTest < Rails::Generators::TestCase
  tests Sitepress::ControllerGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
