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
    namespaces.unshift(gem_name.gsub("-", "_")).join(":")
  end

  def self.all(glob = "**/*.gemspec")
    @all ||= Dir[glob].map{ |path| new path }
  end
end

Project.all.each do |project|
  namespace project.task_namespace do
    Bundler::GemHelper.install_tasks(dir: project.gem_dir, name: project.gem_name)
  end
end

%w[build install install:local release].each do |task|
  desc "#{task.capitalize} all gems"
  task task do
    Project.all.each do |project|
      Rake::Task[project.task_namespace(task)].invoke
    end
  end
end

# Rspec tasks.
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
