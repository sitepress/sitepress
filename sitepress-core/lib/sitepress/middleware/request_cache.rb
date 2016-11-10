module Sitepress
  module Middleware
    # Reloads the Sitepress cache between requests if cache resources is enabled.
    # This ensures that the Sitepress resources are loaded only once per request
    # for development environments so that the site isn're reloaded per call. Used
    # from the Rails app and from the stand-alone Sitepress server.
    class RequestCache
      def initialize(app, site:)
        @app, @site = app, site
      end

      # Cache resources for the duration of the request, even if
      # caching is disabled.
      def call(env)
        cache_resources = @site.cache_resources
        begin
          @site.cache_resources = true
          @app.call env
        ensure
          @site.cache_resources = cache_resources
          @site.clear_resources_cache unless @site.cache_resources
        end
      end
    end
  end
end
