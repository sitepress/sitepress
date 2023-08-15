ENV['BUNDLE_GEMFILE'] ||= 'Gemfile'

require "bundler/setup"     # Set up gems listed in the Gemfile.
require "sitepress/server"  # Load all the stuff needed setup the configuration below.

# Setup defaults for stand-alone Sitepress server in the current path. This
# can, and should, be over-ridden by the end-user in the `config/site.rb` file.
Sitepress.configure do |config|
  config.site = Sitepress::Site.from_root "."
end
