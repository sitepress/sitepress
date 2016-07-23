# Mascot

Mascot is a file-backed website content manager that can be embedded in popular web frameworks like Rails. Inspired by [Middleman](https://middlemanapp.com), Mascot is stripped down with less dependencies to work better within Rails. That mean it ships with Frontmatter, the Sitemap API, and a few templating features. [Learn more about Mascot](https://github.com/bradgessler/mascot).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mascot-rails'
```

And then execute:

```bash
$ bundle
```

Then mount the engine into your `config/routes.rb` file:

```ruby
mount Mascot::Engine => "/"
```

Then add pages to the `app/views/pages` directory:

```bash
$ echo "<h1>Hello</h1><p>It is <%= Time.now %> o'clock</p>" > app/views/pages/hello.html.erb
```

Point your browser to `http://127.0.0.1:3000/hello` and if all went well you should see the page you just created.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
