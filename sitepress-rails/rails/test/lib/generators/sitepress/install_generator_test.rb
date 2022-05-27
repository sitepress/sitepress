require "test_helper"
require "generators/sitepress/install/install_generator"

class Sitepress::InstallGeneratorTest < Rails::Generators::TestCase
  tests Sitepress::InstallGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
