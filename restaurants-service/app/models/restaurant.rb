require_relative "application_record"

class Restaurant < ActiveRecord::Base
  has_many :items, :dependent => :destroy, foreign_key: :restaurant_uuid, primary_key: :uuid
end
