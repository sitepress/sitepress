class SortModel < Sitepress::Model
  collection glob: "**/sort/*.html*", sort: :title
  data :title
end
