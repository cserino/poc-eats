require_relative 'application_handler'
require 'models/restaurant'
require 'models/item'

class ItemsHandler < ApplicationHandler
  def before_action(event:, context:)
    puts "before_action!"
    begin
      @restaurant = Restaurant.find_by_uuid!(event['pathParameters']['restaurant'])
    rescue ActiveRecord::RecordNotFound => err
      return bad_request(err.message, code: 404)
    end
  end

  def index(event:, context:)
    {
      restaurant: @restaurant,
      items: @restaurant.items,
    }
  end
end
