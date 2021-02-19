module ApplicationHelper
  DEFAULT_TITLE_KEY = "title".freeze

  DEFAULT_ORDER_KEY = "order".freeze

  # Links to a Sitepress::Resource. If the link does not have a block, the `title`
  # attribute from Resource#data is used to create the text link.
  def link_to_page(page, *args, title_key: DEFAULT_TITLE_KEY, **kwargs, &block)
    if block_given?
      link_to page.request_path, *args, **kwargs, &block
    else
      link_to page.data[DEFAULT_TITLE_KEY], page.request_path, *args, **kwargs
    end
  end

  # Render a block within a layout. This is a useful, and prefered way, to handle
  # nesting layouts, within Sitepress
  def render_layout(layout, locals = {}, &block)
    render inline: capture(&block), layout: "layouts/#{layout}", locals: locals
  end

  # Orders pages via the
  def order_pages(pages, order_key: DEFAULT_ORDER_KEY)
    pages.sort_by { |r| r.data.fetch(order_key, Float::INFINITY) }
  end
end
