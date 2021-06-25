load "vendor/bundle/bundler/setup.rb"

require 'json'
require 'pg'
require 'active_record'
require_relative 'config'

def db_config
  DBConfig.db_config
end

def create(event:, context:)
  db_config_admin = db_config.merge({database: 'postgres', schema_search_path: 'public'})
  ActiveRecord::Base.establish_connection(db_config_admin)
  connection = ActiveRecord::Base.connection
  puts "creating database #{db_config[:database]}"
  connection.create_database(db_config[:database])
  'OK'
end

def migrate_preview(event:, context:)
  ActiveRecord::Base.establish_connection(db_config)
  context = ActiveRecord::MigrationContext.new(Dir["db/migrate"], ActiveRecord::SchemaMigration)
  migrator = context.open
  puts "Unapplied migrations: #{migrator.pending_migrations}"

  'OK'
end

def migrate(event:, context:)
  ActiveRecord::Base.establish_connection(db_config)
  context = ActiveRecord::MigrationContext.new(Dir["db/migrate"], ActiveRecord::SchemaMigration)
  migrator = context.open
  migrator.migrate

  'OK'
end

def schema_dump(event:, context:)
  require 'stringio'
  require "active_record/schema_dumper"
  ActiveRecord::Base.establish_connection(db_config)
  connection = ActiveRecord::Base.connection

  dump = StringIO.new
  ActiveRecord::SchemaDumper.dump(connection, dump)
  dump.string
end
