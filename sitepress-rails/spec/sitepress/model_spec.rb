require "spec_helper"
require "tmpdir"
require "fileutils"

describe Sitepress::Model do
  let(:site) { Sitepress.site }
  let(:build_path) { Pathname.new(Dir::tmpdir).join("build") }
end
