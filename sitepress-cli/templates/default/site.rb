# Default layout for Sitepress pages
site.manipulate do |resource|
  resource.data["layout"] = "layouts/layout.html.erb" if resource.mime_type == "text/html"
end
