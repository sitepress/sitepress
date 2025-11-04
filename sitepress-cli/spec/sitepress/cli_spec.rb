require "spec_helper"

describe Sitepress::CLI do
  subject { Sitepress::CLI.start(args) }
  context "#server" do
    let(:args) { %w[-c spec/sites/sample/site.rb -p 5000 -b 127.0.0.1] }
    it "calls server"
  end
  context "#compile" do
    let(:args) { %w[-c spec/sites/sample/site.rb -o spec/sites/sample/build] }
    it "calls compiler"
  end
  context "#new" do
    let(:args) { %w[-t default spec/sites/new_site] }
    it "calls new"
  end
end
