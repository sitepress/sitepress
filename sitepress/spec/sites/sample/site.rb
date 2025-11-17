site.root_path = "spec/sites/sample"

site.manipulate do |root|
  root.flatten.each do |resource|
    resource.data["layout"] ||= "layout.html.erb"
  end
end
