class ApplicationLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def template
    doctype

    head do
      title { "Phlex layout" }
    end

    body do
      yield
    end
  end
end
