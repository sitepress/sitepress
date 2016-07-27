require "mascot-server"

sitemap = Mascot::Sitemap.new(root: "spec/pages")
run Mascot::Server.new(sitemap: sitemap)
