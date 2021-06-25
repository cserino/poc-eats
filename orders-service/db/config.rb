require "uri"
require "active_record"
require 'active_record/database_configurations/connection_url_resolver'

module DBConfig
  def self.db_config
    ActiveRecord::DatabaseConfigurations::ConnectionUrlResolver.new(ENV['DATABASE_URL']).to_hash
  end

  def self.init_database!
    ActiveRecord::Base.establish_connection(db_config)
  end
end
