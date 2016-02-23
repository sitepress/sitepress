require "beams/version"

module Beams
  require "yaml"

  # Parses metadata from the header of the page.
  class Frontmatter
    DELIMITER = "---".freeze
    PATTERN = /\A#{DELIMITER}\n(.+)\n#{DELIMITER}\n?(.+)\Z/m

    attr_reader :body

    def initialize(content)
      @data, @body = content.match(PATTERN).captures
    end

    def data
      @data ? YAML.load(@data) : {}
    end

    private
    def parse
      @content
    end
  end

  require "nokogiri"
  require "tilt"

  # Composites metadata from arbitrary sources, such as a page's
  # DOM elements. Great for TOCs, etc.
  class DataPipeline
    extend Forwardable
    def_delegator :@processors, :<<

    def initialize(page)
      @page = page
      @processors = []
    end

    def add(&block)
      @processors << block
    end

    def process
      @processors.reduce Hash.new do |memo, p|
        memo.merge(p.arity.zero? ? p.call : p.call(@page))
      end
    end
  end

  # Represents an HTML page. Doesn't care yet
  # about paths, locations, etc.
  class Page
    Binding = Struct.new(:data)

    def initialize(template: , data: {})
      @template, @data = template, data
    end

    # Query the data on the page. If HTML, use CSS. If
    # JSON, use ...
    def dom
      @dom ||= Nokogiri::HTML(render)
    end

    def data_pipeline
      @data_pipeline ||= DataPipeline.new(self).tap do |pipeline|
        pipeline << lambda { @data }
      end
    end

    def data
      data_pipeline.process
    end

    def render
      @template.render(Object.new, current_page: Binding.new(@data))
    end

    def self.open(path)
      engine = Tilt[path]
      frontmatter = Frontmatter.new File.read(path)
      template = engine.new { |t| frontmatter.body }
      data = frontmatter.data
      new template: template, data: data
    end
  end

  # Represents a page in a web server context.
  class Resource
    CONTENT_TYPE = "text/html".freeze

    attr_reader :request_path, :page, :content_type

    def initialize(request_path: , page: , content_type: CONTENT_TYPE)
      @request_path = request_path
      @page = page
      @content_type = content_type
    end
  end

  # Collection of pages
  class Sitemap
    attr_reader :resources

    def initialize
      @resources = []
    end

    # Find the page with a path.
    def resolve(request_path)
      resources.find { |r| r.request_path == request_path }
    end

    def self.glob(path)
      new.tap do |sitemap|
        Dir[path].each do |path|
          request_path = File.join("/", path).sub(/\..*/, '')
          sitemap.resources << Resource.new(request_path: request_path, page: Page.open(path))
        end
      end
    end
  end

  # Mount inside of a config.ru file to run this as a server.
  class Server
    def initialize(sitemap)
      @sitemap = sitemap
    end

    def self.glob(path = ".")
      new Beams::Sitemap.glob(path)
    end

    def call(env)
      req = Rack::Request.new(env)
      if resource = @sitemap.resolve(req.path)
        [ 200, {"Content-Type" => resource.content_type}, [resource.page.render] ]
      else
        [ 404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end
    end
  end
end
