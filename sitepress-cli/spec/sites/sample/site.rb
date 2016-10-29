site.root_path = "spec/sites/sample"

site.manipulate do |resource|
  resource.data["layout"] ||= "layout.html.erb"
end
