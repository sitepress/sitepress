# Changelog

## 5.0.0.beta4

### New Features

- **Multi-site Rails apps** - You can now serve any number of Sitepress sites from one Rails app via the new `Sitepress.sites` registry. The whole API is two top-level methods: `Sitepress.site` (the configured default, unchanged) and `Sitepress.sites` (the registry of additional sites). The registry has three operations — `<<` to add, `fetch` to look up by `root_path` (raises `NotFoundError` listing registered paths on miss), and `each` plus the rest of `Enumerable` for iteration.

  ```ruby
  # config/initializers/sitepress.rb
  Sitepress.sites << Sitepress::Site.new(root_path: "app/content/admin_docs")

  # app/controllers/admin/docs_controller.rb
  class Admin::DocsController < Sitepress::SiteController
    self.site = Sitepress.sites.fetch("app/content/admin_docs")
  end

  # config/routes.rb
  namespace :admin do
    scope :docs do
      sitepress_pages controller: "admin/docs", as: :admin_doc
    end
  end
  ```

  See the multi-site section of the README for the full architecture.

- **`class_attribute :site` on `Sitepress::SitePages`** - Controllers bind themselves to a site with `self.site = ...`. The writer also `prepend_view_path`s the site's view directories onto *this controller's* lookup chain (idempotently — dev reloads don't grow the path list), so multi-site view lookups stay local instead of polluting global ActionView paths.

- **`sitepress_pages controller: "..."`** - The route helper now accepts a `controller:` argument and reads the site to guard via `controller_class.site`, with the mount path inferred from the surrounding `scope`/`namespace`. Multi-site mounting requires zero duplication of the mount path between routes and controllers.

- **`bin/rails generate sitepress:site <path>`** - New Rails generator that scaffolds a Sitepress site for the multi-site flow. Creates the content directory tree (`pages/`, `helpers/`, `models/`, `assets/` with `.keep` files), a stub `pages/index.html.erb`, an `<Name>Controller < Sitepress::SiteController` with `self.site = Sitepress.sites.fetch(...)` already filled in, and either creates or appends to `config/initializers/sitepress.rb` with the registration line. Pass `--mount-at=/path/to/mount` to also inject a `scope` block into `config/routes.rb`; without the flag the generator just prints the routes line for you to paste.

- **`Sitepress::Compilers` collection class** - A small Enumerable wrapper for running a bunch of compilers in one call. Holds anything responding to `#compile` (typically `Sitepress::Compiler::Files`, but also custom backends like `Compiler::SQLite`) and runs them in order. The collection has no opinion about how its members were constructed, where they write, or what sites they're bound to.

  ```ruby
  # Add one at a time
  compilers = Sitepress::Compilers.new
  compilers << Sitepress::Compiler::Files.new(site: foo, root_path: "build/foo")
  compilers << Sitepress::Compiler::Files.new(site: bar, root_path: "build/bar")
  compilers.compile

  # Or merge an iterable in one call (mirrors Array#concat semantics)
  Sitepress::Compilers.new
    .concat(sites.map { |s| Sitepress::Compiler::Files.new(site: s, root_path: "build/#{s.root_path.basename}") })
    .compile

  # Aggregate stats across members via Enumerable
  compilers.flat_map(&:succeeded).count
  compilers.flat_map(&:failed).count
  ```

- **Multi-site rake tasks** - Single-site and multi-site compilation are split into separate tasks so adding a registered site doesn't change the bare `sitepress:compile` behavior:

  - `rake sitepress:compile` — compiles the configured default site only.
  - `rake sitepress:sites:compile` — compiles every registered site (default + `Sitepress.sites`) to `tmp/sitepress/<basename of root_path>`.
  - `rake "sitepress:sites:compile[app/content/admin_docs]"` — compiles a single registered site by `root_path`. Raises `Sitepress::NotFoundError` listing registered paths on miss.
  - `rake sitepress:sites` — lists the configured default site and every site registered in `Sitepress.sites`. Useful for "is my site actually loaded?" debugging without dropping into a Rails console.

  Set `OUTPUT_PATH=build` to override the default `tmp/sitepress` build root for either compile task — useful in CI and deploy flows. Set `FAIL_ON_ERROR=true` to raise on the first resource that fails to render and abort rake with a non-zero exit (default `false` collects all failures and prints a summary at the end).

  After every compile run the rake tasks print a `Compilation Summary` block listing how many sites were built, how many resources succeeded/failed, and (if any failed) the path of every failing resource paired with the site it lives in. Useful for catching individual broken pages without scrolling through per-site streams.

- **`Sitepress.sites << ...` is now type-checked and boot-ordering-aware.** Pushing anything other than a `Sitepress::Site` instance raises `ArgumentError` at the call site (catches the common `Sitepress.sites << "path"` mistake). Pushing a Site after the engine's path-setup pass has finished — e.g. from `config.after_initialize` or inside a request — logs a warning that the helpers/models/assets won't be picked up by Zeitwerk, instead of letting the silent half-broken state propagate.

- **Engine path-setup is split into two initializers** to handle the Rails initializer ordering correctly. The default site's helpers/models/assets/views are registered in `sitepress.set_default_site_paths` (runs `before: :set_autoload_paths`, populates `config.autoload_paths` the normal way). Sites registered in `Sitepress.sites` from `config/initializers/sitepress.rb` are picked up in `sitepress.set_registered_site_paths` (runs `after: :load_config_initializers`), which pushes directories directly to `Rails.autoloaders.main` since `config.autoload_paths` is frozen by that phase. This is the fix for "I called `Sitepress.sites <<` in an initializer but my helper isn't autoloading" — the engine wasn't seeing registered sites until after this split.

### Breaking Changes

- **Removed Sprockets-era `manifest_file_path`.** `Sitepress::RailsConfiguration#manifest_file_path` and the engine initializer that consumed it (`sitepress.set_manifest_file_path`) are gone. 5.x uses Propshaft, which has no manifest file concept.

## 5.0.0.beta1

### Breaking Changes

- **Removed deprecated `collection glob:` syntax** - Use block-based `collection` or `glob` method instead:
  ```ruby
  # Before (removed)
  collection :pages, glob: "**/*.html*"

  # After
  def self.all = glob("**/*.html*")
  # or
  collection { site.glob("**/*.html*") }
  ```

- **New sitepress-server gem** - The development server has been extracted into a separate gem with Falcon replacing Rackup/Puma. This brings async I/O and better performance for development.

- **Server configuration changed** - The `config/site.rb` configuration now uses `ApplicationServer`:
  ```ruby
  # Before
  Sitepress.configuration.site = Sitepress::Site.new(root_path: ".")

  # After
  site = Sitepress::Site.new(root_path: ".")
  Sitepress.server = Sitepress::ApplicationServer.new(site)
  Sitepress.server.live_reload = true
  ```

### New Features

- **Falcon-based development server** - New `sitepress-server` gem provides a fast async development server:
  - Uses Falcon for async HTTP handling
  - Server-Sent Events (SSE) for instant browser reloading
  - Automatic script injection into all HTML responses (including error pages)
  - Clean shutdown on Ctrl+C

- **Process supervision** - Run build tools alongside the development server:
  ```ruby
  Sitepress.server.add_process :css, "tailwindcss -w -i ./app.css -o ./public/app.css"
  Sitepress.server.add_process :js, "esbuild app.js --bundle --watch --outdir=public"
  ```
  Processes run concurrently with colored, labeled output.

- **Browser reloading** - Automatic page refresh when files change:
  - Watches pages, helpers, and assets directories
  - SSE-based for instant updates (no polling)
  - Logs file changes with timestamps:
    ```
    Files changed at 2026-02-23 12:19:33 -0800
      Modified /path/to/pages/index.html.erb
    Reloading 1 client(s)
    ```

- **MIME-based source routing** - Directory now routes files to appropriate source types based on MIME type:
  - `Image` - PNG, JPEG, GIF, WebP (provides dimensions via fastimage)
  - `Page` - HTML, Markdown, Haml, ERB, SVG, and other text formats (supports frontmatter)
  - `Static` - Fallback for all other file types

- **Source class inheritance** - `Image` and `Page` now inherit from `Static`, sharing common behavior:
  - All sources use `Path` for consistent path parsing
  - `fetch_data(key)` method includes file path in KeyError messages for easier debugging

- **Console improvements** - Added command history (persists to ~/.irb_history) and simple prompt

- **Better frontmatter error messages** - `fetch_data` method on Page and Resource includes file path in KeyError:
  ```ruby
  page.fetch_data(:title)  # KeyError: key not found: :title in pages/about.html.md
  ```

- **CLI integration tests** - Added integration tests for `new`, `server`, `console`, `compile`, and `version` commands

### Improvements

- **Cleaner inspect output** - Resource and source classes now show meaningful inspect output:
  ```ruby
  #<Sitepress::Resource:0x... request_path="/about" source=#<Sitepress::Page:0x... path="pages/about.html.md">>
  ```

- **Improved error page** - Better developer experience with:
  - "Copy Error" button for easy LLM debugging
  - App trace shown by default, framework trace in collapsible details
  - Cleaned up ugly ERB-generated method names in stack traces
  - Proper file paths in stack traces instead of "inline template"

- **Compile command supports both asset pipelines** - Works with Sprockets and Propshaft

### Bug Fixes

- **Fixed `sitepress compile` with Sprockets** - Handle `Sprockets::CachedEnvironment` and use Rails precompile config

- **Fixed error page crashing** - Handle non-Page sources that don't have `body_line_offset`

### Gem Structure

The sitepress ecosystem now consists of three gems:

- **sitepress-core** - Core abstractions (Site, Resource, Node, Page, Image, etc.)
- **sitepress-rails** - Rails integration for embedding Sitepress in Rails apps
- **sitepress-server** - Falcon-based development server with process supervision
- **sitepress** - CLI and standalone site support (depends on all three above)
