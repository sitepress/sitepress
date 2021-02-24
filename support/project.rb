module Sitepress
  class Project
    # I had to order these to make it possible to test local installations;
    # otherwise if I tried to run `rake build install`, it wouldn't be able
    # to find the latest version if it was sooner.
    GEMSPEC_PATHS = %w[
      sitepress-core
      sitepress-rails
      sitepress-server
      sitepress-cli
      sitepress
    ]

    def initialize(gemspec_path)
      @gemspec_path = gemspec_path
    end

    def gem_dir
      File.join(Dir.pwd, File.dirname(@gemspec_path))
    end

    def gem_name
      File.basename(@gemspec_path, ".gemspec")
    end

    def task_namespace(*namespaces)
      namespaces.unshift(gem_name.tr("-", "_")).join(":")
    end

    def chdir
      gemfile_location = ENV["BUNDLE_GEMFILE"]
      ENV["BUNDLE_GEMFILE"] = File.join(Dir.pwd, "Gemfile")
      Dir.chdir gem_dir do
        puts "Switching to #{Dir.pwd}"
        yield if block_given?
      end
      ENV["BUNDLE_GEMFILE"] = gemfile_location
      puts "Back to #{Dir.pwd}"
    end

    def self.all(glob = "**/*.gemspec")
      @all ||= ordered_gemspec_paths.map{ |path| new path }
    end

    def self.ordered_gemspec_paths
      GEMSPEC_PATHS.map{ |spec| File.join(spec, "#{spec}.gemspec") }
    end
  end
end
