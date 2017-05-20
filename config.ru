# frozen_string_literal: true
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dotenv'
Dotenv.load

require 'slackjirabot'
require 'web'

Thread.abort_on_exception = true

Thread.new do
  begin
    SlackJiraBot::Bot.run
  rescue StandardError => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

# Turn off debug logging
Slack.configure do |config|
  # your logger
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::WARN
end

SlackRubyBot::Client.logger.level = Logger::WARN

if ENV['HEROKU_URL']
  Thread.new do
    require 'net/http'
    require "uri"
    loop do
      sleep 5 * 60
      uri = URI.parse(ENV['HEROKU_URL'])
      Net::HTTP.get_response(uri)
    end
  end
end

run SlackJiraBot::Web

