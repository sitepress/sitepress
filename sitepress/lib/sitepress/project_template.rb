require "fileutils"

module Sitepress
  # Creates new projects from a template.
  class ProjectTemplate
    DEFAULT_TEMPLATE = File.expand_path("../../../templates/default",__FILE__).freeze

    include FileUtils

    def initialize(path: DEFAULT_TEMPLATE)
      @path = path
    end

    def copy(to:)
      cp_r @path, to
    end

    def bundle
      Dir.chdir @path do
      end
    end
  end
end
