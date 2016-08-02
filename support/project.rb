module Mascot
  class Project
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
      @all ||= Dir[glob].map{ |path| new path }
    end
  end
end
