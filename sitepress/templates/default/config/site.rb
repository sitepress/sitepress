# Configure your Sitepress site
site = Sitepress::Site.new(root_path: ".")

# Configure the development server
Sitepress.server = Sitepress::ApplicationServer.new(site)
Sitepress.server.live_reload = true

# Add build processes (uncomment to enable)
# Sitepress.server.add_process :css, "tailwindcss -w -i ./assets/stylesheets/site.css -o ./public/site.css"
# Sitepress.server.add_process :js, "esbuild ./assets/javascripts/site.js --outdir=./public --watch"
