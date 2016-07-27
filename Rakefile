# frozen_string_literal: true

# Gem build/release tasks.
require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"

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
    Dir.chdir gem_dir do
      puts "Switching to #{Dir.pwd}"
      yield if block_given?
    end
    puts "Back to #{Dir.pwd}"
  end

  def self.all(glob = "**/*.gemspec")
    @all ||= Dir[glob].map{ |path| new path }
  end
end

Project.all.each do |project|
  namespace project.task_namespace do
    # Install gem tasks.
    Bundler::GemHelper.install_tasks(dir: project.gem_dir, name: project.gem_name)

    desc "Run specs for #{project.gem_name}"
    task :spec do
      puts "Verifying #{project.gem_name}"
      ENV["BUNDLE_GEMFILE"] = File.join(Dir.pwd, "Gemfile")
      project.chdir { sh "bundle exec rspec" }
    end
  end
end

%w[build install install:local release spec].each do |task|
  desc "#{task.capitalize} all gems"
  task task do
    Project.all.each do |project|
      Rake::Task[project.task_namespace(task)].invoke
    end
  end
end

desc "Run benchmarks"
task :benchmark do
  files = Dir["./benchmarks/**_benchmark.rb"]
  sh "ruby #{files.join(" ")}"
end

desc "Run CI tasks"
task ci: %w[spec benchmark]

task :default => :spec
