class SiteController < Sitepress::SiteController
  # Override this method to implement your processing logic for Sitepress pages.
  def show
    render_resource current_resource
  end

  protected

  # This is to be used by end users if they need to do any post-processing on the rendering page.
  # For example, the user may use Nokogiri to parse static HTML pages and hook it into the asset pipeline.
  # They may also use tools like `HTMLPipeline` to process links from a markdown renderer.
  #
  # For example, the rendition could be modified via `Nokogiri::HTML5::DocumentFragment(rendition)`.
  def process_rendition(rendition)
    # Do nothing unless the user extends this method.
  end
end
