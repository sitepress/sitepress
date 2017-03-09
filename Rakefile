# frozen_string_literal: true

require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"
require_relative "support/project"

Sitepress::Project.all.each do |project|
  namespace project.task_namespace do
    # Install gem tasks.
    Bundler::GemHelper.install_tasks(dir: project.gem_dir, name: project.gem_name)

    desc "Run specs for #{project.gem_name}"
    task :spec do
      puts "Verifying #{project.gem_name}"
      Bundler.with_clean_env do
        project.chdir do
          sh "bundle exec rspec"
        end
      end
    end
  end
end

%w[build install install:local release spec].each do |task|
  desc "#{task.capitalize} all gems"
  task task do
    Sitepress::Project.all.each do |project|
      Rake::Task[project.task_namespace(task)].invoke
    end
  end
end

desc "Run benchmarks"
task :benchmark do
  Dir["./benchmarks/**_benchmark.rb"].each do |benchmark|
    sh "ruby #{benchmark}"
  end
end

desc "Run CI tasks"
task ci: %w[spec benchmark]

desc "Install gems locally"
task install_local: %w[build sitepress_core:install:local sitepress_server:install:local sitepress_cli:install:local sitepress:install:local]

task :default => :spec
