# Beams

Beams is an experimental data-driven static site generator.

![](https://upload.wikimedia.org/wikipedia/commons/6/6a/Building_a_Skyscraper._Placing_steel_beams,_Metropolitan_Tower,_New_York_City,_from_Robert_N._Dennis_collection_of_stereoscopic_views.jpg)

[![Build Status](https://travis-ci.org/bradgessler/beams.svg?branch=master)](https://travis-ci.org/bradgessler/beams)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beams'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install beams

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

Beams is capable of building data pipelines like this:

```ruby
page = Beams::Page.open("spec/pages/test.html.haml")
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

Traditional static site generators assume a tight mapping between a directory structure and URL. Beams aims to be more decoupled from the file system and more data driven.

For example, a page can be manually added to the resources:

```ruby
sitemap = Beams::Sitemap
sitemap.resources << Beams::Resource.new(request_path: "/my/page", page: Beams::Page.new("./photos.html.erb"))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradgessler/beams.

