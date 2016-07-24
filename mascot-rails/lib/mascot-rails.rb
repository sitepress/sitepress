require "mascot"
require "mascot/route_constraint"
require "mascot/action_controller_context"
require "mascot/engine"

module Mascot
  Configuration = Struct.new(:sitemap, :routes, :parent_engine)

  def self.configure(&block)
    block.call configuration
  end

  def self.configuration
    @configuration ||= Configuration.new(
      Sitemap.new(file_path: Rails.root.join("app/pages")),
      true,
      Rails.application)
  end
end
