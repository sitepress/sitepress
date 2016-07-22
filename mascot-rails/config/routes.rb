Rails.application.routes.draw do
  constraints Mascot::RouteConstraint.new(Mascot.sitemap) do
    get "/*path", controller: "mascot/sitemap", action: "show", as: :page, format: false
  end
end
