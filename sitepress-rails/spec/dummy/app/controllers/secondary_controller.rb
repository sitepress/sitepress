class SecondaryController < Sitepress::SiteController
  self.site = Sitepress.sites.fetch(Rails.root.join("app/sitepress/secondary").to_s)
end
