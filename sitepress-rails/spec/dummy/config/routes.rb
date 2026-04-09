Rails.application.routes.draw do
  get "/baseline/render", to: "baseline#show"

  scope "secondary" do
    sitepress_pages controller: "secondary", as: :secondary_page
  end

  sitepress_pages
end
