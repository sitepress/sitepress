require "mascot"
require "mascot/route_constraint"
require "mascot/action_controller_context"
require "mascot/engine"

module Mascot
  # Singleton for rails app integration & configuration.
  def self.sitemap
    @sitemap ||= Sitemap.new(file_path: "app/views/pages")
  end
end
