require_relative "application_record"

class Restaurant < ActiveRecord::Base
  has_many :items, :dependent => :destroy
end
