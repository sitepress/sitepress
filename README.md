# Sitepress

Sitepress is a file-backed website content manager that can be embedded in popular web frameworks like Rails, run stand-alone, or be compiled into static sites. Its useful for marketing pages or small websites that you need to deploy within your web frameworks.

It features:

* Wide support for templates incuding Erb, Haml, Slim, and more.
* Static site compilation to S3, Netlify, etc.
* Embedable in Rails monoliths
* Frontmatter
* Page models
* Helpers

[![Build status](https://github.com/sitepress/sitepress/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/sitepress/sitepress/actions/workflows/test.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/14edce5d81e1892d2836/maintainability)](https://codeclimate.com/github/sitepress/sitepress/maintainability)

## Installation

### Rails Installation

It all starts by running the following from the root of your rails project:

```ruby
bundle add sitepress-rails
```

Then follow the instructions in the [Sitepress Rails](./sitepress-rails) gem.

### Standalone Installation

Install the Sitepress gem on your system:

    $ gem install sitepress

Then create a new site:

    $ sitepress new my-site

Sitepress will create a new site and download and install the gems it needs. Once that's done run:

    $ cd my-site

Then start the Sitepress development server:

    $ sitepress server

You should then see the site at http://localhost:8080/. Time to start building something beautiful!

# Features

Sitepress implements a subset of the best features from the [Middleman](http://www.middlemanapp.com/) static site generator including the Site and Parsers::Frontmatter.

## Frontmatter

Frontmatter is a way to attach metadata to content pages. Its a powerful way to enable a team of writers and engineers work together on content. The engineers focus on reading values from frontmatter while the writers can change values.

```haml
---
title: This is a swell doc
meta:
  keywords: this, is, a, test
background_color: #0f0
---

%html
  %head
    %meta(name="keywords" value="#{current_page.data.dig("meta", "keywords")}")
  %body(style="background: #{current_page.data["background_color"]};")
    %h1=current_page.data["title"]
    %p And here's the rest of the content!
```

## Site

The Site accepts a directory path

```irb
> site = Sitepress::Site.new(root_path: "spec/pages")
=> #<Sitepress::Site:0x007fcd24103710 @root=#<Pathname:spec/pages>, @request_path=#<Pathname:/>>
```

Then you can request a resource by request path:

```irb
> resource = site.get("/test")
=> #<Sitepress::Resource:0x007fcd2488a128 @request_path="/test", @content_type="text/html", @file_path=#<Pathname:spec/pages/test.html.haml>, @frontmatter=#<Sitepress::Parsers::Frontmatter:0x007fcd24889e80 @data="title: Name\nmeta:\n  keywords: One", @body="\n!!!\n%html\n  %head\n    %title=current_page.data[\"title\"]\n  %body\n    %h1 Hi\n    %p This is just some content\n    %h2 There\n">>
```

And access the frontmatter data (if available) and body of the template.

```irb
> resource.data
=> {"title"=>"Name", "meta"=>{"keywords"=>"One"}}
> resource.body
=> "\n!!!\n%html\n  %head\n    %title=current_page.data[\"title\"]\n  %body\n    %h1 Hi\n    %p This is just some content\n    %h2 There\n"
```

### Resource globbing

The Site API is a powerful way to query content via resource globbing. For example, if you have a folder full of files but you only want all `.html` files within the `docs` directory, you'd do something like:

```haml
%ol
  -site.resources.glob("docs/*.html*").each do |page|
    %li=link_to page.data["title"], page.request_path
```

## Architecture

Sitepress has a layered architecture that separates concerns: reading files, organizing them into a tree, and presenting them with domain logic.

### Overview

```
┌─────────────────────────────────────────────────────────┐
│  PageModel (optional)                                   │
│  - Domain logic, computed properties                    │
│  - Wraps Resources, hoists data to methods              │
├─────────────────────────────────────────────────────────┤
│  Resource                                               │
│  - URL/request path, format, MIME type                  │
│  - Tree navigation (parent, children, siblings)         │
│  - Wraps a Source                                       │
├─────────────────────────────────────────────────────────┤
│  Source (Page, Image, or custom)                        │
│  - Reads files, provides data and body                  │
│  - Page: text with frontmatter, renderable              │
│  - Image: binary with dimensions                        │
├─────────────────────────────────────────────────────────┤
│  Node                                                   │
│  - Tree structure (parent, children)                    │
│  - Holds Resources by format                            │
├─────────────────────────────────────────────────────────┤
│  Site                                                   │
│  - Entry point, builds tree from files                  │
│  - Provides get/glob methods to query resources         │
└─────────────────────────────────────────────────────────┘
```

### Building a Tree Manually

Understanding how to build a tree manually helps clarify how the pieces fit together.

```ruby
require "sitepress-core"

# The root node is the top of the tree. Nodes represent positions
# in the URL hierarchy, like directories in a filesystem.
root = Sitepress::Node.new

# Sources know how to read files. A Page reads text files with
# optional YAML frontmatter. An Image reads binary image files
# and extracts dimensions.
homepage = Sitepress::Page.new(path: "pages/index.html.erb")
logo = Sitepress::Image.new(path: "pages/logo.png")

# Resources connect Sources to Nodes. A Resource has a format
# (html, png, etc.) and knows its request path based on its
# position in the tree.
#
# Here we add the homepage to the root node. The "index" child
# node is created automatically.
root.child("index").resources.add_source(homepage, format: :html)

# Multiple formats can exist at the same node. This is how
# /about.html and /about.json can coexist.
root.child("logo").resources.add_source(logo, format: :png)

# Now we can query the tree:
root.get("/index")           # => Resource (homepage)
root.get("/index").data      # => {"title" => "Welcome"} (from frontmatter)
root.get("/index").body      # => "<h1>Hello</h1>..." (template body)

root.get("/logo")            # => Resource (logo)
root.get("/logo").data       # => {"width" => 200, "height" => 100}
root.get("/logo").source.width  # => 200
```

### Sources: Page and Image

Sources are responsible for reading files and providing a consistent interface.

```ruby
# Page reads text files with optional YAML frontmatter.
# It's renderable through template handlers (ERB, Haml, etc.)
page = Sitepress::Page.new(path: "about.html.erb")
page.data          # => {"title" => "About Us"} (from frontmatter)
page.body          # => "<h1>About</h1>..." (template content)
page.format        # => :html
page.mime_type     # => #<MIME::Type: text/html>
page.renderable?   # => true

# Image reads binary image files and extracts dimensions.
# It's not renderable - you serve the binary directly.
image = Sitepress::Image.new(path: "photo.jpg")
image.data         # => {"width" => 1920, "height" => 1080}
image.body         # => binary content
image.format       # => :jpg
image.mime_type    # => #<MIME::Type: image/jpeg>
image.width        # => 1920
image.height       # => 1080
```

### Resources and Tree Navigation

Resources wrap Sources and provide tree navigation filtered by format.

```ruby
# Get a resource
about = site.get("/about")

# Tree navigation returns resources of the same format by default
about.parent          # => Resource at "/" (html format)
about.children        # => [Resource, Resource, ...] (html children)
about.siblings        # => [Resource, Resource, ...] (html siblings)

# This makes iteration natural - you're always dealing with
# the same type of content:
about.children.each do |child|
  puts child.data["title"]  # Works because all children are html pages
end
```

### Custom Sources

You can create custom sources for other file types by implementing the source interface:

```ruby
class VideoSource
  attr_reader :path

  def initialize(path:)
    @path = Pathname.new(path)
  end

  def format
    path.extname.delete(".").to_sym
  end

  def mime_type
    MIME::Types.type_for(path.to_s).first
  end

  def data
    # Extract video metadata (duration, dimensions, codec, etc.)
    @data ||= Sitepress::Data.manage({
      "width" => video_width,
      "height" => video_height,
      "duration" => video_duration
    })
  end

  def body
    File.binread(path)
  end
end
```

Then configure the `AssetNodeMapper` (or subclass it) to use your custom source for video files.

### Page Models (Optional)

Page models add domain logic on top of resources. They're decoupled from resources - a single resource can be used by multiple page models.

```ruby
class Photo
  def initialize(resource)
    @resource = resource
  end

  # Hoist data to methods
  def title
    @resource.data["title"] || filename_as_title
  end

  def width
    @resource.data["width"]
  end

  def height
    @resource.data["height"]
  end

  # Add computed properties
  def landscape?
    width > height
  end

  def thumbnail_url
    "#{@resource.request_path}?size=thumb"
  end

  # Class method to find all photos
  def self.all(site)
    site.resources.select { |r| r.source.is_a?(Sitepress::Image) }
                  .map { |r| new(r) }
  end

  private

  def filename_as_title
    @resource.source.filename.sub(/\.\w+$/, "").gsub(/[-_]/, " ").capitalize
  end
end

# Usage in templates:
Photo.all(site).each do |photo|
  puts "#{photo.title}: #{photo.width}x#{photo.height}"
  puts "Landscape!" if photo.landscape?
end
```

### Backwards Compatibility

For backwards compatibility, `Sitepress::Asset` is an alias for `Sitepress::Page`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sitepress/sitepress.
