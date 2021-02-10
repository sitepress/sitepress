Sitepress.configuration.parent_engine.routes.draw do
  if Sitepress.configuration.routes
    constraints Sitepress::RouteConstraint.new do
      get "*resource_path", controller: "sitepress/site", action: "show", as: :page, format: false
      root to: "sitepress/site#show"
    end
  end
end
