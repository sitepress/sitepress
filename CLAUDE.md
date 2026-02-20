# Sitepress Architecture

## Core Abstractions

**Site** → **Node** → **Resource** → **Source** (Page, Image) → **PageModel** (optional)

- **Source**: Reads files, provides `data`, `body`, `format`, `mime_type`
  - `Page`: Text files with optional YAML frontmatter (renderable)
  - `Image`: Binary images with dimensions via fastimage
- **Resource**: Wraps a Source, adds tree navigation (parent, children, siblings)
- **Node**: Tree structure, holds Resources by format
- **Site**: Entry point, builds tree from files

## Mount Interface

Anything with `#mount(node)` can be added to the tree via `<<`:

```ruby
site.root << Directory.new("./pages")
site.root.child("docs") << Directory.new("./docs")
```

`Directory` (formerly AssetNodeMapper) maps a filesystem directory into nodes.

## Backwards Compatibility Aliases

- `Asset` → `Page`
- `AssetNodeMapper` → `Directory`

## Design Principles

- Mappers are "recipes" - they don't hold state, can be mounted multiple times
- Sources are decoupled from Resources - same source could be used differently
- Tree navigation is format-aware (children returns same format by default)
