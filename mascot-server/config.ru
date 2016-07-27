require "mascot-server"

sitemap = Mascot::Sitemap.new(root_dir: "spec/pages")
run Mascot::Server.new(sitemap: sitemap)
