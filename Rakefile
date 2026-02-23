# frozen_string_literal: true

require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"
require "appraisal"
require_relative "support/project"

Sitepress::Project.all.each do |project|
  namespace project.task_namespace do
    # Install gem tasks.
    Bundler::GemHelper.install_tasks(dir: project.gem_dir, name: project.gem_name)

    desc "Uninstall #{project.gem_name}"
    task :uninstall do
      sh "gem uninstall #{project.gem_name} --force --executables"
    end

    desc "Run specs for #{project.gem_name}"
    task :spec do
      failed_projects = []

      puts "Verifying #{project.gem_name}"
      project.chdir do
        sh "bundle exec rspec" do |ok, res|
          if not ok
            failed_projects << project.gem_name
            puts res
          end
        end
      end

      # This will properly return a non-zero error code if the suite fails.
      fail "#{failed_projects.map(&:inspect).join(", ")} suites failed" if failed_projects.any?
    end
  end
end

%w[build install install:local release spec uninstall].each do |task|
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

desc "Show current version of Sitepress"
task :version do
  puts Sitepress::VERSION
end

desc "Install gems locally"
task install_local: %w[build sitepress_core:install:local sitepress_rails:install:local sitepress:install:local]

task :default => :spec
