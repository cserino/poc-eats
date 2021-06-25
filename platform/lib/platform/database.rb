# frozen_string_literal: true

require "uri"
require "active_record"
require 'active_record/database_configurations/connection_url_resolver'

module Platform
  def self.db_config
    ActiveRecord::DatabaseConfigurations::ConnectionUrlResolver.new(ENV['DATABASE_URL']).to_hash
  end

  def self.init_database!
    ActiveRecord::Base.establish_connection(db_config)
  end

  def self.handle_database_event(function_name, event, context)
    event_name = function_name[(function_name.index('-db-') + 4) .. -1].gsub('-', '_').to_sym
    throw "Unknown event: #{event_name}" unless DatabaseEventHandlers.respond_to? event_name
    DatabaseEventHandlers.send(event_name, event, context)
  end

  module DatabaseEventHandlers
    def self.create(event, context)
      db_config_admin = Platform.db_config.merge({database: 'postgres', schema_search_path: 'public'})
      ActiveRecord::Base.establish_connection(db_config_admin)
      connection = ActiveRecord::Base.connection
      puts "creating database #{db_config[:database]}"
      connection.create_database(db_config[:database])
      'OK'
    end

    def self.migrate_preview(event, context)
      ActiveRecord::Base.establish_connection(Platform.db_config)
      context = ActiveRecord::MigrationContext.new(Dir["db/migrate"], ActiveRecord::SchemaMigration)
      migrator = context.open
      puts "Unapplied migrations: #{migrator.pending_migrations}"

      'OK'
    end

    def self.migrate(event, context)
      ActiveRecord::Base.establish_connection(Platform.db_config)
      context = ActiveRecord::MigrationContext.new(Dir["db/migrate"], ActiveRecord::SchemaMigration)
      migrator = context.open
      migrator.migrate

      'OK'
    end

    def self.schema_dump(event, context)
      require 'stringio'
      require "active_record/schema_dumper"
      ActiveRecord::Base.establish_connection(Platform.db_config)
      connection = ActiveRecord::Base.connection

      dump = StringIO.new
      ActiveRecord::SchemaDumper.dump(connection, dump)
      dump.string
    end
  end
end
