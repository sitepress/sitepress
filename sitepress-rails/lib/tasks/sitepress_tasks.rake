# OUTPUT_PATH overrides the default tmp/sitepress build root for both
# `sitepress:compile` and `sitepress:sites:compile`. CI and deploy
# flows that want a different location (`build/`, `dist/`,
# `public/static/`) set OUTPUT_PATH on the invocation:
#
#   OUTPUT_PATH=build rake sitepress:sites:compile
SITEPRESS_COMPILE_OUTPUT_ROOT = -> {
  ENV.fetch("OUTPUT_PATH") { Rails.root.join("tmp/sitepress").to_s }
}

# FAIL_ON_ERROR=true makes the compile rake tasks raise on the first
# resource that fails to render, aborting rake with a non-zero exit.
# Default (false) collects all failures and prints a summary at the
# end so a single bad page doesn't block the rest of the build —
# preferred for local iteration. Use FAIL_ON_ERROR=true in CI to make
# deploys notice broken pages.
SITEPRESS_FAIL_ON_ERROR = -> { ENV["FAIL_ON_ERROR"] == "true" }

# Build a Compiler::Files for `site`, writing into a subdirectory of
# `output_root` named after the site's basename. Used by both
# `sitepress:compile` and `sitepress:sites:compile` so they agree on
# the on-disk layout (each site in its own directory under the build
# root, no two sites colliding).
SITEPRESS_BUILD_COMPILER = ->(site, output_root, fail_on_error: false) {
  Sitepress::Compiler::Files.new(
    site: site,
    root_path: Pathname(output_root).join(site.root_path.expand_path.basename.to_s),
    fail_on_error: fail_on_error
  )
}

# Print a "Compilation Summary" block to stdout after a compile run.
# Aggregates succeeded/failed counts across every compiler in the
# collection and lists each failed resource with its owning site so
# the user can see exactly what broke.
SITEPRESS_PRINT_COMPILE_SUMMARY = ->(compilers) {
  succeeded = compilers.flat_map(&:succeeded).size
  failed    = compilers.flat_map(&:failed)

  puts ""
  puts "Compilation Summary"
  puts "  Sites:      #{compilers.size}"
  puts "  Succeeded:  #{succeeded}"
  puts "  Failed:     #{failed.size}"

  if failed.any?
    puts ""
    puts "Failed Resources"
    compilers.each do |compiler|
      compiler.failed.each do |resource|
        puts "  #{compiler.site.root_path}: #{resource.request_path}"
      end
    end
  end
}

namespace :sitepress do
  desc "Compile the configured default Sitepress site to OUTPUT_PATH (default: tmp/sitepress/<basename>)"
  task compile: :environment do
    require "sitepress/compiler"
    output_root = SITEPRESS_COMPILE_OUTPUT_ROOT.call
    fail_on_error = SITEPRESS_FAIL_ON_ERROR.call

    compilers = Sitepress::Compilers.new
    compilers << SITEPRESS_BUILD_COMPILER.call(Sitepress.site, output_root, fail_on_error: fail_on_error)
    compilers.compile

    SITEPRESS_PRINT_COMPILE_SUMMARY.call(compilers)
  end

  desc "List the configured default site and all sites in Sitepress.sites"
  task sites: :environment do
    puts "Default:"
    puts "  #{Sitepress.site.root_path}"

    if Sitepress.sites.any?
      puts ""
      puts "Registered (#{Sitepress.sites.count}):"
      Sitepress.sites.each do |site|
        puts "  - #{site.root_path}"
      end
    else
      puts ""
      puts "No additional sites registered. Use Sitepress.sites << Sitepress::Site.new(root_path: ...) in an initializer."
    end
  end

  namespace :sites do
    desc "Compile every registered Sitepress site (default + Sitepress.sites) to OUTPUT_PATH (default: tmp/sitepress/<basename>)"
    task :compile, [:root_path] => :environment do |_task, args|
      require "sitepress/compiler"
      output_root = SITEPRESS_COMPILE_OUTPUT_ROOT.call
      fail_on_error = SITEPRESS_FAIL_ON_ERROR.call

      # When invoked as `rake sitepress:sites:compile` we compile
      # everything; when invoked as `rake "sitepress:sites:compile[path]"`
      # we compile just the matching site (raising NotFoundError with
      # the registered paths listed if no match).
      sites = if args[:root_path]
        [Sitepress.sites.fetch(args[:root_path])]
      else
        [Sitepress.site, *Sitepress.sites]
      end

      compilers = Sitepress::Compilers.new.concat(
        sites.map { |site| SITEPRESS_BUILD_COMPILER.call(site, output_root, fail_on_error: fail_on_error) }
      )
      compilers.compile

      SITEPRESS_PRINT_COMPILE_SUMMARY.call(compilers)
    end
  end
end
