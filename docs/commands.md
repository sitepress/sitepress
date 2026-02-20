# Sitepress CLI Commands

Sitepress has a command extension system that allows gems to add new CLI subcommands. Command extensions are standard Ruby gems that register Thor command classes.

## Using Command Extensions

### Installation

Add the command gem to your `Gemfile`:

```ruby
source "https://rubygems.org"

gem "sitepress"
gem "sitepress-deploy"      # Adds deployment commands
gem "sitepress-import"      # Adds content import commands
```

Run `bundle install` and the commands are immediately available:

```bash
$ sitepress help
Commands:
  sitepress compile           # Compile project into static pages
  sitepress console           # Interactive project shell
  sitepress deploy SUBCOMMAND # Deploy your site
  sitepress import SUBCOMMAND # Import content from external sources
  sitepress new PATH          # Create new project at PATH
  sitepress server            # Run preview server
  sitepress version           # Show version
```

### Running Commands

Commands work like any other `sitepress` command:

```bash
# See what a command offers
$ sitepress deploy help
Commands:
  sitepress deploy netlify  # Deploy to Netlify
  sitepress deploy s3       # Deploy to AWS S3
  sitepress deploy help     # Show this help message

# Run a command
$ sitepress deploy s3 --bucket my-site --region us-west-2

# Get help for a specific subcommand
$ sitepress deploy help s3
Usage:
  sitepress deploy s3

Options:
  --bucket=BUCKET  # S3 bucket name (required)
  --region=REGION  # AWS region (default: us-east-1)

Deploy compiled site to AWS S3
```

### Command Configuration

Commands may add configuration options to `config/site.rb`:

```ruby
# config/site.rb
Sitepress.configure do |config|
  # Core Sitepress config
  config.site = Sitepress::Site.new(root_path: "content")

  # Command-specific config (if the command supports it)
  config.deploy.default_target = :netlify
  config.deploy.netlify_site_id = ENV["NETLIFY_SITE_ID"]
end
```

Check each command gem's documentation for available configuration options.

---

## Creating Command Extensions

Command extensions are Ruby gems that register Thor command classes with Sitepress.

### Quick Start

Create a new gem:

```bash
$ bundle gem sitepress-deploy
$ cd sitepress-deploy
```

### Gem Structure

```
sitepress-deploy/
├── lib/
│   ├── sitepress-deploy.rb           # Main entry point
│   └── sitepress/
│       └── deploy/
│           ├── version.rb
│           └── cli.rb                 # Thor commands
├── sitepress-deploy.gemspec
└── README.md
```

### Step 1: Configure the Gemspec

Add the `sitepress_command` metadata so Sitepress discovers your gem:

```ruby
# sitepress-deploy.gemspec
Gem::Specification.new do |spec|
  spec.name    = "sitepress-deploy"
  spec.version = Sitepress::Deploy::VERSION
  spec.summary = "Deployment commands for Sitepress"

  # Required: This tells Sitepress to load your command
  spec.metadata["sitepress_command"] = "true"

  # Depend on sitepress-cli for the command helpers
  spec.add_dependency "sitepress-cli", ">= 5.0"

  # Your command's dependencies
  spec.add_dependency "aws-sdk-s3", "~> 1.0"
end
```

### Step 2: Create the CLI Class

Define your commands as a Thor class:

```ruby
# lib/sitepress/deploy/cli.rb
require "thor"

module Sitepress
  module Deploy
    class CLI < Thor
      # Include helpers for accessing Sitepress environment
      include Sitepress::CLI::CommandHelpers

      desc "s3", "Deploy to AWS S3"
      long_desc <<~DESC
        Compiles your site and uploads it to an S3 bucket configured
        for static website hosting.

        Example:
          $ sitepress deploy s3 --bucket my-site --region us-west-2
      DESC
      option :bucket, required: true, type: :string, desc: "S3 bucket name"
      option :region, default: "us-east-1", type: :string, desc: "AWS region"
      option :delete, type: :boolean, default: false, desc: "Delete removed files"
      def s3
        # Lazy-load heavy dependencies
        require "aws-sdk-s3"

        say "Compiling site..."
        compile_site

        say "Uploading to s3://#{options[:bucket]}..."
        upload_to_s3

        say "Deploy complete!", :green
      end

      desc "netlify", "Deploy to Netlify"
      option :site_id, required: true, type: :string, desc: "Netlify site ID"
      option :auth_token, type: :string, desc: "Netlify auth token (or set NETLIFY_AUTH_TOKEN)"
      def netlify
        require "sitepress/deploy/netlify"

        token = options[:auth_token] || ENV["NETLIFY_AUTH_TOKEN"]
        abort "Missing auth token" unless token

        Sitepress::Deploy::Netlify.new(
          site_id: options[:site_id],
          token: token,
          path: compile_site
        ).deploy!

        say "Deployed to Netlify!", :green
      end

      private

      def compile_site
        # Access the site through the helper
        compiler = Sitepress::Compiler::Files.new(
          site: site,
          root_path: build_path
        )
        compiler.compile
        build_path
      end

      def build_path
        @build_path ||= Dir.mktmpdir("sitepress-deploy")
      end

      def upload_to_s3
        client = Aws::S3::Client.new(region: options[:region])

        Dir.glob("#{build_path}/**/*").each do |file|
          next if File.directory?(file)

          key = file.sub("#{build_path}/", "")
          say "  Uploading #{key}"

          client.put_object(
            bucket: options[:bucket],
            key: key,
            body: File.read(file),
            content_type: Marcel::MimeType.for(name: file)
          )
        end
      end
    end
  end
end
```

### Step 3: Register the Command

In your main require file, register with Sitepress:

```ruby
# lib/sitepress-deploy.rb
require "sitepress/deploy/version"
require "sitepress/deploy/cli"

# Register the command when Sitepress is available
if defined?(Sitepress::Commands)
  Sitepress::Commands.register(
    name: "deploy",                        # The subcommand name
    cli: Sitepress::Deploy::CLI,           # Your Thor class
    description: "Deploy your site"        # Shown in `sitepress help`
  )
end
```

### Available Helpers

When you `include Sitepress::CLI::CommandHelpers`, you get these methods:

| Method | Description |
|--------|-------------|
| `site` | The `Sitepress::Site` instance with all resources |
| `configuration` | The `Sitepress.configuration` object |
| `rails` | The parent Rails application |
| `logger` | The Rails logger |
| `app` | The `Sitepress::Server` Rails application |

The Sitepress environment is automatically booted before your command runs, so you can access `site`, `configuration`, and other helpers immediately.

You also get all of [Thor::Actions](https://www.rubydoc.info/gems/thor/Thor/Actions) for file operations and user interaction:

```ruby
# Thor::Actions examples
say "Hello!", :green           # Colored output
ask "Continue?"                # User input
yes? "Delete files?"           # Yes/no prompt
run "npm install"              # Shell commands
create_file "config.yml"       # Create files
template "config.erb", "out"   # ERB templates
```

### Adding a Rails Engine (Optional)

If your command needs initializers, configuration, or other Rails integration:

```ruby
# lib/sitepress/deploy/engine.rb
module Sitepress
  module Deploy
    class Engine < ::Rails::Engine
      isolate_namespace Sitepress::Deploy

      initializer "sitepress-deploy.configure" do |app|
        # Add configuration namespace
        Sitepress.configuration.class.class_eval do
          attr_accessor :deploy
        end
        Sitepress.configuration.deploy = Configuration.new
      end
    end

    class Configuration
      attr_accessor :default_target, :netlify_site_id, :s3_bucket
    end
  end
end

# lib/sitepress-deploy.rb
require "sitepress/deploy/engine"  # Load the engine
require "sitepress/deploy/cli"
# ... rest of registration
```

Users can then configure your command:

```ruby
# config/site.rb
Sitepress.configure do |config|
  config.deploy.default_target = :s3
  config.deploy.s3_bucket = "my-site"
end
```

### Testing Your Command

```ruby
# spec/sitepress/deploy/cli_spec.rb
require "spec_helper"

RSpec.describe Sitepress::Deploy::CLI do
  describe "commands" do
    it "has s3 command" do
      expect(described_class.commands).to have_key("s3")
    end

    it "has netlify command" do
      expect(described_class.commands).to have_key("netlify")
    end
  end

  describe "s3 command" do
    let(:command) { described_class.commands["s3"] }

    it "requires bucket option" do
      expect(command.options[:bucket].required).to be true
    end

    it "has default region" do
      expect(command.options[:region].default).to eq("us-east-1")
    end
  end
end
```

### Publishing Your Command

1. Ensure your gemspec has `spec.metadata["sitepress_command"] = "true"`
2. Write a good README with usage examples
3. Push to RubyGems: `gem push sitepress-deploy-1.0.0.gem`

Users can then install with:

```ruby
gem "sitepress-deploy"
```

---

## Command Ideas

Here are some commands that would be useful:

| Command | Description |
|---------|-------------|
| `sitepress-deploy` | Deploy to S3, Netlify, Vercel, Cloudflare Pages |
| `sitepress-import` | Import from WordPress, Notion, Ghost, Markdown folders |
| `sitepress-images` | Optimize images, generate responsive sizes, WebP conversion |
| `sitepress-search` | Generate search index (Lunr, Algolia, Pagefind) |
| `sitepress-feed` | Generate RSS/Atom/JSON feeds |
| `sitepress-sitemap` | Generate XML sitemaps |
| `sitepress-check` | Validate links, check accessibility, lint HTML |

---

## Troubleshooting

### Command not appearing in `sitepress help`

1. Check that your gemspec has `spec.metadata["sitepress_command"] = "true"`
2. Ensure the gem is in your Gemfile and installed
3. Verify the registration runs: add `puts "Registering!"` before `Sitepress::Commands.register`

### Command conflicts

If two gems register the same command name, the first one loaded wins. You'll see a warning:

```
WARNING: Sitepress command 'deploy' is already registered, skipping
```

Rename your command or coordinate with the other gem author.
