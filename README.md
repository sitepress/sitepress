# Mascot

Mascot is a file-backed website content manager that can be embedded in popular web frameworks like Rails, run stand-alone, or be compiled into static sites. Its useful for marketing pages or small websites that you need to deploy within your web frameworks.

[![Build Status](https://travis-ci.org/bradgessler/mascot.svg?branch=master)](https://travis-ci.org/bradgessler/mascot) [![Code Climate](https://codeclimate.com/github/bradgessler/mascot/badges/gpa.svg)](https://codeclimate.com/github/bradgessler/mascot) [![Test Coverage](https://codeclimate.com/github/bradgessler/mascot/badges/coverage.svg)](https://codeclimate.com/github/bradgessler/mascot/coverage)

## Installation

### Rails Installation

Follow the instructions in the [Mascot Rails](./mascot-rails) gem.

### Standalone Installation

Add this line to your application's Gemfile:

```ruby
gem 'mascot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mascot

## Usage

Given a the file `hi.html.haml`:

```haml
---
title: Name
meta:
  keywords: One
---

!!!
%html
  %head
    %title=current_page.data["title"]
  %body
    %h1 Hi
    %p This is just some content
    %h2 There
```

Mascot can parse out the frontmatter and body to render inside your framework of choice, like Rails:

```ruby
class MascotController < ApplicationController
  def show
    mascot.render "/hi"
  end
end
```

so when you call `current_page.data` from your templates, you get something like this:

```irb
> current_page.data
=> {"title"=>"Name", "meta"=>{"keywords"=>"One"}, "toc"=>["Hi", "There"]}
> current_page.data.dig("meta", "keywords")
=> "One"
```

Mascot is designed to be embedded in rails and other Ruby web frameworks.

# Features

Mascot implements a subset of the best features from the [Middleman](http://www.middlemanapp.com/) static site generator including the Site and Frontmatter.

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
> site = Mascot::Site.new(root: "spec/pages")
=> #<Mascot::Site:0x007fcd24103710 @root=#<Pathname:spec/pages>, @request_path=#<Pathname:/>>
```

Then you can request a resource by request path:

```irb
> resource = site.get("/test")
=> #<Mascot::Resource:0x007fcd2488a128 @request_path="/test", @content_type="text/html", @file_path=#<Pathname:spec/pages/test.html.haml>, @frontmatter=#<Mascot::Frontmatter:0x007fcd24889e80 @data="title: Name\nmeta:\n  keywords: One", @body="\n!!!\n%html\n  %head\n    %title=current_page.data[\"title\"]\n  %body\n    %h1 Hi\n    %p This is just some content\n    %h2 There\n">>
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradgessler/mascot.
