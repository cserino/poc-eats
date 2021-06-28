require_relative 'application_handler'
require 'models/restaurant'

class RestaurantsHandler < ApplicationHandler
  def index(event:, context:)
    return_response(:restaurants, Restaurant.all)
  end

  def show(event:, context:)
    begin
      restaurant = Restaurant.find(event['pathParameters']['restaurant'])
    rescue ActiveRecord::RecordNotFound => err
      return bad_request(err.message)
    end
    return_response(:restaurant, restaurant)
  end

  def create(event:, context:)
    method = event.dig('requestContext', 'http', 'method')
    if method == 'POST'
      p 'POST Request'
      p "event body is #{event['body']}"
      return bad_request("body cannot be empty") if event['body'].nil?
      body = JSON.parse(event['body'])
    end
    white_list_params = [:uuid, :name]
    params = body.keep_if { |k, v| white_list_params.include?(k.to_sym) }
    restaurant = Restaurant.new(params)

    if restaurant.save
      return_response(:restaurant, restaurant)
    else
      bad_request(restaurant.errors)
    end
  end
end
