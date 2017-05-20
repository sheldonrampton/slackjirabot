require 'redis'
require 'json'

module SlackJiraBot
  class Data
    def self.redis
      @redis ||= Redis.new(url: ENV['REDISTOGO_URL'] || nil)
    end

    def self.get_customer(key)
      customer_data = redis.get(key)
      customer_data.nil? ? {
        :account_code => '',
        :slug => '',
        :abbrev => 'NOT FOUND',
        :domain => '',
        :fullname => '',
        :https => false,
        :dev_site => '',
        :stage_site => '',
        :prod_site => '',
        :repo => '',
        :dkan_version => '',
        :hosting => '',
        :subscription => '',
        :synonyms => '',
      } : JSON.parse(customer_data)
    end

    def self.set_customer(key, data)
      redis.set(key, data.to_json)
    end
  end
end
