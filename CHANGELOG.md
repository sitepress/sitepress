# Changelog

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
