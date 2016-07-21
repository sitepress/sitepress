require "mascot-server"

sitemap = Mascot::Sitemap.new(file_path: "spec/pages")
run Mascot::Server.new(sitemap: sitemap)
