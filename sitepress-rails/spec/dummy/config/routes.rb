Rails.application.routes.draw do
  get "/baseline/render", to: "baseline#show"
  sitepress_pages
end
