# frozen_string_literal: true
require 'sinatra/base'

module SlackJiraBot
  class Web < Sinatra::Base
    get '/' do
      'Jirabots are good for you'
    end
  end
end
