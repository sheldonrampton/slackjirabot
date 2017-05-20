# frozen_string_literal: true
require 'slack-ruby-bot'
require 'slack-ruby-client'
require 'slackjirabot/commands/config'
require 'slackjirabot/commands/code_release'
require 'slackjirabot/commands/help'
require 'slackjirabot/commands/set'
require 'slackjirabot/commands/get'
require 'slackjirabot/commands/describe'
require 'slackjirabot/commands/qa'
require 'slackjirabot/commands/bug'
require 'slackjirabot/commands/task'
require 'slackjirabot/commands/enhancement'
require 'slackjirabot/bot'
require 'slackjirabot/data'
require 'slackjirabot/ticket'
require 'slackjirabot/cr_ticket'
require 'slackjirabot/ticket_list'
require 'slackjirabot/settings_list'
require 'slackjirabot/jira_client'
require 'lib/confluence/api/client'