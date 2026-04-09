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

## Multiple sites in a single Rails app

You can serve any number of Sitepress sites from one Rails app — for example a marketing site at `/` and an admin docs site at `/admin/docs`. Three pieces, plain Ruby:

```ruby
# 1. config/initializers/sitepress.rb — register the site at boot
Sitepress.sites << Sitepress::Site.new(root_path: "app/sitepress/admin_docs")
```

```ruby
# 2. app/controllers/admin/docs_controller.rb — bind it to a controller
class Admin::DocsController < Sitepress::SiteController
  self.site = Sitepress.sites.fetch("app/sitepress/admin_docs")

  layout "admin"
  before_action :require_admin
end
```

```ruby
# 3. config/routes.rb — mount the controller
Rails.application.routes.draw do
  sitepress_pages   # default site at /

  namespace :admin do
    scope :docs do
      sitepress_pages controller: "admin/docs", as: :admin_doc
    end
  end
end
```

The whole multi-site API is two methods on `Sitepress`: `Sitepress.site` (the configured default, unchanged) and `Sitepress.sites` (the registry). The registry has three operations — `<<` to add, `fetch` to look up by `root_path` (raises `NotFoundError` listing registered paths on miss), and `each` plus the rest of `Enumerable` for iteration.

A typo in the path string fails loud at controller class load:

```
NotFoundError: No Sitepress site registered at "app/contnet".
Registered: ["app/sitepress/admin_docs"]
```

**Why three pieces and not one?** Boot ordering forces it. Zeitwerk needs helper / model paths registered before its eager-load pass, which happens before the first request — that's what `Sitepress.sites <<` does and it's the only piece that *has* to live in an initializer. The controller binding (`self.site = ...`) is just `class_attribute` plus a writer that `prepend_view_path`s the site's view directories onto *this controller's* lookup chain (so multi-site view lookups stay local — no global ActionView pollution). Routes own the URL → controller binding, with the mount path read from the surrounding `scope`/`namespace`.

The same site can be referenced by more than one controller — a public reader and an admin editor can both `Sitepress.sites.fetch("...")` and bind to the same content tree. The Site itself is registered once.

### Generator

```bash
bin/rails generate sitepress:site app/sitepress/admin_docs
```

Scaffolds the content directory tree (`pages/`, `helpers/`, `models/`, `assets/`), a stub index template, a controller subclass with `self.site = Sitepress.sites.fetch(...)` already filled in, and either creates or appends to `config/initializers/sitepress.rb` with the registration line. Pass `--mount-at=/admin/docs` to also inject a `scope` block into `config/routes.rb`; without the flag, the generator just prints the routes line for you to paste.

### Rake tasks

Compilation is split into single-site and multi-site forms so single-site users don't get a behavior change when they add a registered site:

- `rake sitepress:compile` — compiles the configured default site only.
- `rake sitepress:sites:compile` — compiles every registered site (default + `Sitepress.sites`) to `tmp/sitepress/<basename>`. Each site lives in its own subdirectory so two sites never collide on output.
- `rake "sitepress:sites:compile[app/sitepress/admin_docs]"` — compiles a single registered site by `root_path`. Raises `Sitepress::NotFoundError` listing registered paths if no match.
- `rake sitepress:sites` — lists the configured default site and everything in `Sitepress.sites`.

Two env vars adjust the compile tasks:

- `OUTPUT_PATH=build rake sitepress:sites:compile` — overrides the default `tmp/sitepress` build root.
- `FAIL_ON_ERROR=true rake sitepress:sites:compile` — raises on the first resource that fails to render. Default (`false`) collects all failures and prints a summary at the end.

After every compile run, the tasks print a `Compilation Summary` block listing how many sites were built, how many resources succeeded/failed, and (if any failed) the path of every failing resource paired with the site it lives in.

These tasks only handle content compilation. Run your asset bundler (Propshaft, esbuild, Tailwind, etc.) separately if you have static assets to build.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
