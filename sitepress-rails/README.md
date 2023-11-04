# Sitepress

Sitepress is a file-backed website content manager that can be embedded in popular web frameworks like Rails. Inspired by [Middleman](https://middlemanapp.com), Sitepress is stripped down with less dependencies to work better within Rails. That mean it ships with Frontmatter, the Site API, and a few templating features. [Learn more about Sitepress](https://github.com/sitepress/sitepress).

## Installation

Add `sitepress-rails` to a Rails application by running:

```ruby
bundle add sitepress-rails
```

The install content pages by running:

```bash
$ ./bin/rails generate sitepress:install
```

This command creates a few content pages and adds the following to the `config/routes.rb` file:

```ruby
sitepress_pages
sitepress_root # Delete if you don't want your app's root page to be a content page.
```

Restart the Rails application server and point your browser to `http://127.0.0.1:3000/` and if all went well you should see a sitepress page.

## Using with Phlex Components & Layouts

Sitepress will work with Phlex, all you have to do is use frontmatter to specify your Phlex layout as the chosen layout for the page:

```ruby
---
layout: ApplicationLayout
---
```

Case is important here, the `layout` must match the case of your layout component's class, as the name will be `#constantized`.

Sitepress will automatically work if you have chosen to use a Phlex layout as the `ApplicationController`'s layout like so:

```ruby
class ApplicationController < ActionController::Base
  layout -> { ApplicationLayout }
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
