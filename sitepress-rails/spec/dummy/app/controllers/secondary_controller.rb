class SecondaryController < Sitepress::SiteController
  self.site = Sitepress.sites.fetch(Rails.root.join("app/content/secondary").to_s)
end
