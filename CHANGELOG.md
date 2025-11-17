# Changelog

All notable changes to Sitepress will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.0.0] - Unreleased

### Changed

**BREAKING: Removed deprecated collection syntax**

The old macro-style collection definition has been removed:

```ruby
# ❌ Old (removed):
class MyModel < Sitepress::Model
  collection :posts, glob: "posts/*.html"
end

# ✅ New (use instead):
class MyModel < Sitepress::Model
  def self.posts = glob("posts/*.html")
end
```

Or use `collection` with a block directly:

```ruby
collection { site.glob("posts/*.html") }
```

**BREAKING: Replaced Sprockets with Propshaft for asset pipeline**

Sitepress 5.0 replaces Sprockets with Propshaft as the default asset pipeline. Propshaft is a simpler, more modern asset handling system that focuses on serving assets as-is with fingerprinting, without the complexity of asset compilation and transpilation.

#### Migration Guide

**For most users:** No changes required if you're using basic assets (images, plain CSS, plain JavaScript).

**If you were relying on Sprockets features:**

1. **Asset Compilation:** Propshaft does not compile or transpile assets (SCSS, CoffeeScript, etc.)
   - **SCSS/Sass:** Use a separate build tool (like `dartsass-sprockets`, `dartsass-rails`, or a JavaScript-based tool)
   - **CoffeeScript:** Migrate to plain JavaScript or use a separate build tool
   - **Asset concatenation:** Use a JavaScript bundler (esbuild, rollup, webpack) or import maps

2. **Asset Directives:** Propshaft does not support Sprockets directives (`//= require`, `//= require_tree`, etc.)
   - Remove directive comments from JavaScript files
   - Use ES6 imports, import maps, or a JavaScript bundler instead

3. **Asset References:** Asset helper methods work the same way
   - `image_tag "logo.svg"` → generates correct path to `logo-DIGEST.svg`
   - `stylesheet_link_tag "site"` → generates correct path to `site-DIGEST.css`
   - `javascript_include_tag "app"` → generates correct path to `app-DIGEST.js`

#### What's Different

**Propshaft vs Sprockets:**

| Feature | Sprockets | Propshaft |
|---------|-----------|-----------|
| Asset fingerprinting | ✅ Yes | ✅ Yes |
| Serves static assets | ✅ Yes | ✅ Yes |
| Compiles SCSS/Sass | ✅ Yes | ❌ No |
| Compiles CoffeeScript | ✅ Yes | ❌ No |
| Asset directives | ✅ Yes | ❌ No |
| Asset concatenation | ✅ Yes | ❌ No |
| Complexity | High | Low |

**Benefits of Propshaft:**

- **Simpler:** No compilation pipeline, just fingerprinting
- **Faster:** Less processing overhead
- **Modern:** Designed for modern CSS and JavaScript
- **Predictable:** What you put in is what you get out (with fingerprints)

#### Technical Changes

**Dependency Changes:**
- Removed: `sprockets-rails >= 2.0.0`
- Added: `propshaft >= 0.1.7`

**Code Changes:**
- `sitepress-rails`: Updated to require `propshaft/railtie` instead of `sprockets/railtie`
- `sitepress-server`: Updated to require `propshaft/railtie` instead of `sprockets/railtie`
- `sitepress-cli`: Updated asset compilation to use Propshaft's `Processor` API

**API Changes:**
- Asset compilation now uses `Propshaft::Processor.new` with explicit configuration
- Manifest format remains compatible (JSON-based)

### Fixed

- **Template:** Renamed `site.css.scss` to `site.css` in default template
  - The file contained plain CSS with no SCSS features
  - Propshaft serves files as-is, so `.scss` files are not compiled
  - This fixes compilation errors in newly generated sites

### Added

- **Tests:** Comprehensive test coverage for CLI commands (26 new tests)
  - `sitepress new`: Verifies all directories and files are created correctly
  - `sitepress compile`: Verifies assets are compiled with Propshaft fingerprints
  - Asset pipeline integration: Verifies compiled HTML references digested assets correctly
  - Tests verify specific digested asset filenames (e.g., `logo-brown-bb6b6291.svg`)

### Documentation

- Updated all references from Sprockets to Propshaft in:
  - Template README
  - Template index page
  - Code comments
  - JavaScript file headers

---

## [4.1.1] - Previous Release

See git history for changes in 4.x releases.