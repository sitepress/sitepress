# Getting started

Welcome to your new Sitepress site! If you know Rails, you'll feel right at home in Sitepress because it's built on top of Rails. There's a few things you'll need to know to get around:

## Starting the preview server

First thing you'll want to do is start the preview server:

```sh
$ sitepress server
```

Then open http://127.0.0.1:8080 and you'll see the welcome page.

## Layouts

To specify a layout for a page, add a `layout` key to the pages frontmatter. For example, if I create the layout `tech-support`, I'd add the following frontmatter to the top of a page in `pages/support/router.html.md`:

```md
---
title: How to fix a router
layout: tech-support
---

# How to fix a router

1. Unplug the router.
2. Plug in the router.
```

Sitepress will look for the layout in the `layouts` folder from the `layout` key in the file's frontmatter.

Additionally, you may use the `render_layout` function in a page, or layout, to nest the layouts. For example, you could:

```haml
---
title: How to fix a scanner
---
= render_layout "tech-support" do
  %h1 How to fix a scanner

  %ol
    %li Unplug the scanner.
    %li Plug in the scanner.
```

The `render_layout` can be used to nest a layout within a layout, which is a very powerful way to compose content pages.

## File locations

Like Rails, Sitepress organizes files in certain directories:

* `pages` - This is where you'll edit the content. All `erb`, `haml`, and `md` files will be rendered and all other files will be served up. Support for other templating languages should work if you add them to the Gemfile and they already work with Rails.

* `layouts` - Layouts for all pages may be found in this directory. Layouts are great for headers, footer, and other content that you'd otherwise be repeating across the files in `pages`.

* `helpers` - Complex view code that you don't want to live in `page` or `layouts` can be extracted into helpers and re-used throughout the website. These are just like Rails helpers.

* `assets` - If you want Sprockets to fingerprint and manage images, stylesheets, or scripts then put them in the `assets` directory.

* `config` - All configuration files and initializers belong in this directory. The `config/site.rb` file has settings that can be changed for the Sitepress site. Changes made to this file require the `sitepress server` to be restarted.

* `components` - Location of view component files.

## Compiling & publishing the website

Once you're satisfied with your website and you're ready to compile it into static HTML files, run `sitepress compile` and the website will be built to `./build`.

## It's just Rails

Anything you can do in Rails, you can do in Sitepress. If you find yourself needing more Rails for Sitepress, you could try adding it to the `Gemfile` and integrating it into your website. You can also embed and integrate Sitepress into a full-blown Rails app and serve up the content without statically compiling it.

## More info

Check out https://sitepress.cc for the latest and most up-to-date Sitepress documentation.
