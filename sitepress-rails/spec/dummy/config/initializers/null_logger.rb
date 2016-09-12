require "logger"
Rails.application.config.logger = Logger.new("/dev/null")
