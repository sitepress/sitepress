# Sitepress Architecture

## Core Concepts

Sitepress separates **file concerns** from **web-serving concerns** through two main abstractions:

### Source (File on Disk)

Sources represent files on disk. They use `Pathname` for simple file operations and know nothing about web serving, handlers, or URL paths.

**Source classes:**
- `Static` - Base class for all sources. Provides `path`, `body`, `data`, `mime_type`, `exists?`
- `Image` - Extends Static with image dimensions (`width`, `height`) via fastimage
- `Page` - Extends Static with frontmatter parsing (`data`, `body` from YAML frontmatter)

**What Sources know:**
- File path (Pathname)
- File content (body)
- Metadata (data)
- MIME type (based on file extension)
- Whether the file exists

**What Sources DON'T know:**
- Template handlers (erb, haml, md)
- Output format (html, xml, json)
- URL/request paths
- How to render for the web

### Resource (Web Representation)

Resources wrap Sources and add web-serving concerns. They use `Path` to parse filenames and determine how to serve the content.

**What Resources know:**
- Handler (erb, haml, md) - parsed from filename
- Format (html, xml, json) - parsed from filename
- Node name - for building the site tree
- Request path - the URL path
- How to render (`render_in`)
- MIME type for web response

**Example:**

```ruby
# Source: just a file
page = Page.new(path: "about.html.erb")
page.path   # => Pathname("about.html.erb")
page.body   # => "<h1><%= title %></h1>"
page.data   # => {"title" => "About Us"}

# Resource: web representation
resource = Resource.new(source: page, node: node)
resource.handler      # => :erb
resource.format       # => :html
resource.request_path # => "/about"
resource.render_in(view_context)  # renders the template
```

## Class Hierarchy

```
Static (base source)
├── Image (adds dimensions)
└── Page (adds frontmatter parsing)

Resource (wraps any source for web serving)

Directory (scans files, creates sources, builds resource tree)
```

## Data Flow

```
1. Directory scans files
2. Creates appropriate Source (Static, Image, or Page) based on MIME type
3. Parses filename with Path to get node_name, format, handler
4. Creates Resource wrapping the Source
5. Adds Resource to the node tree
6. Rails renders Resources (not Sources) via render_in
```

## Key Design Decisions

1. **Sources use Pathname** - Simple file operations, no web concerns
2. **Resources use Path** - Parses handler/format/node_name from filename
3. **Only Resources can render** - `render_in` is on Resource, not Source
4. **Directory bridges the gap** - Creates Sources, parses paths, builds Resources

This separation means:
- Sources can be tested without web framework dependencies
- The same Source could be served different ways by different Resources
- Web-serving logic is centralized in Resource
