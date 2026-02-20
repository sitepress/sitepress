# Changelog

## 5.0.0.beta

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

- **Rackup 2.0.0 required** - Updated minimum rackup version to 2.0.0 (1.x was a stub gem)

### New Features

- **MIME-based source routing** - Directory now routes files to appropriate source types based on MIME type:
  - `Image` - PNG, JPEG, GIF, WebP (provides dimensions via fastimage)
  - `Page` - HTML, Markdown, Haml, ERB, SVG, and other text formats (supports frontmatter)
  - `Static` - Fallback for all other file types

- **Console improvements** - Added command history (persists to ~/.irb_history) and simple prompt

- **CLI integration tests** - Added integration tests for `new`, `server`, `console`, `compile`, and `version` commands

### Improvements

- **Cleaner inspect output** - Resource and source classes now show meaningful inspect output:
  ```ruby
  #<Sitepress::Resource:0x... request_path="/about" source=#<Sitepress::Page:0x... path="pages/about.html.md">>
  ```

### Bug Fixes

- **Fixed `sitepress server` not starting** - Corrected rackup require path (`rackup/server` instead of `rackup`)
