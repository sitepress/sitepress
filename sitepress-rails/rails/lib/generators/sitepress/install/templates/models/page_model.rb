class PageModel < Sitepress::Model
  def self.all = glob "**/*.html*"
  data :title
end
