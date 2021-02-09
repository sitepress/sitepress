module Sitepress
  # module ApplicationHelper
  # end

  module ApplicationHelper
    def link_to_page(page, **args, &block)
      if block_given?
        link_to page.request_path, **args, &block
      else
        link_to page.data["title"], page.request_path, **args
      end
    end

    def wrap_layout(layout, locals = {}, &block)
      render inline: capture(&block), layout: "layouts/#{layout}", locals: locals
    end

    # SLOP
    def order_pages(pages)
      pages.sort_by { |r| r.data.fetch("order", Float::INFINITY) }
    end

    def order_glob(glob)
      order_pages site.resources.glob(glob).select{ |r| r.data.has_key? "title" }
    end

    def link_to_page(page)
      resource = case page
      when Sitemap::Resource
        page
      else
        site.resources.get(page)
      end

      link_to page.data.fetch("title", page.request_path), page.request_path
    end

    def link_to_if_current(text, page)
      if page == current_page
        link_to text, page.request_path, class: "active"
      else
        link_to text, page.request_path
      end
    end
  end

end
