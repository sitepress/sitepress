# Mascot

Mascot is a file-backed website content manager that can be embedded in popular web frameworks like Rails, run stand-alone, or be compiled into static sites.

[![Build Status](https://travis-ci.org/bradgessler/mascot.svg?branch=master)](https://travis-ci.org/bradgessler/mascot)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mascot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mascot

## Usage

Given a haml file like:

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

Mascot is capable of building data pipelines like this:

```ruby
page = Mascot::Page.open("spec/pages/test.html.haml")
page.data_pipeline.add do |page|
  { "toc" => page.css("h1,h2,h3,h4,h5,h6").map(&:content) }
end
```

so when you call `page.data` you get something like this:

```irb
> page.data
=> {"title"=>"Name", "meta"=>{"keywords"=>"One"}, "toc"=>["Hi", "There"]}
```

## Goals & Big Dreams

### Sitemap

Traditional static site generators assume a tight mapping between a directory structure and URL. Mascot aims to be more decoupled from the file system and more data driven.

For example, a page can be manually added to the resources:

```ruby
sitemap = Mascot::Sitemap
sitemap.resources << Mascot::Resource.new(request_path: "/my/page", page: Mascot::Page.new("./photos.html.erb"))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradgessler/mascot.

