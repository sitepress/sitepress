Sitepress.configuration.parent_engine.routes.draw do
  if Sitepress.configuration.routes
    constraints Sitepress::RouteConstraint.new do
      get "*resource_path", controller: "sitepress/site", action: "show", as: :page, format: false
      if has_named_route? :root
        Rails.logger.warn 'Sitepress tried to configure `root to: "sitepress/site#show"`, but a root route was already defined.'
      else
        root to: "sitepress/site#show"
      end
    end
  end
end
