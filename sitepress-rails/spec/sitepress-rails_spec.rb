require "spec_helper"
require "sitepress-rails"

describe "Sitepress.configuration" do
  subject { Sitepress.configuration }
  let(:app) { Dummy::Application.new }
  before do
    # Why set to true? Because according to Rails:
    #
    #  .config.eager_load is set to nil. Please update your config/environments/*.rb files accordingly:
    #
    #    * development - set it to false
    #    * test - set it to false (unless you use a tool that preloads your test environment)
    #   * production - set it to true
    #
    # The view initializer for haml runs in a `ActiveSupport.on_load(:action_view)`, which requires
    # `eager_load = true` to test.
    app.config.eager_load = true
  end
  it "has Rails.application as parent engine" do
    app.initialize!
    expect(subject.parent_engine).to eql(app)
  end
  it "has routes enabled by default" do
    app.initialize!
    expect(subject.routes).to be true
  end
  it "sets Sitepress::Path.template_extensions" do
    app.initialize!
    expect(Sitepress::Path.handler_extensions).to eql([:raw, :erb, :html, :builder, :ruby])
  end
end
