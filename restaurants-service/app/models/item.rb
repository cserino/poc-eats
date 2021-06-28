require_relative 'application_record'
require_relative 'restaurant'

class Item < ActiveRecord::Base
  belongs_to :restaurant
end
