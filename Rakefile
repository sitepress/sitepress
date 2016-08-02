# frozen_string_literal: true

require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"
require_relative "support/project"

Mascot::Project.all.each do |project|
  namespace project.task_namespace do
    # Install gem tasks.
    Bundler::GemHelper.install_tasks(dir: project.gem_dir, name: project.gem_name)

    desc "Run specs for #{project.gem_name}"
    task :spec do
      puts "Verifying #{project.gem_name}"
      project.chdir { sh "bundle exec rspec" }
    end
  end
end

%w[build install install:local release spec].each do |task|
  desc "#{task.capitalize} all gems"
  task task do
    Mascot::Project.all.each do |project|
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

task :default => :spec
