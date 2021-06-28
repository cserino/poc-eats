load "vendor/bundle/bundler/setup.rb"
$LOAD_PATH.unshift(File.expand_path("./app", __dir__))

require 'platform'
Platform.init_database!

require 'json'
require 'aws-sdk-lambda'
require 'models/restaurant'
require 'active_record'

def lambda_client(service)
  Aws::Lambda::Client.new(
    endpoint: ENV.fetch(
      "SERVICE_#{service.upcase}_LAMBDA_URL",
      'AWS_LAMBDA_URL',
      )
  )
end

def db_event(event:, context:)
  # ENV['AWS_LAMBDA_FUNCTION_NAME'] is set by the AWS sdk
  Platform.handle_database_event(ENV['AWS_LAMBDA_FUNCTION_NAME'], event, context)
end

def index(event:, context:)
  return_response(:restaurants, Restaurant.all)
end

def show(event:, context:)
  begin
    restaurant = Restaurant.find(event['pathParameters']['uuid'])
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

def echo_request(event:, context:)
  body, uuid = '', ''

  if event['httpMethod'] == 'POST'
    return bad_request if event['body'].nil?
    body = JSON.parse(event['body'])
  else
    uuid = event['pathParameters']['uuid']
  end

  {
    statusCode: 200,
    body: {
      uuid: uuid,
      path_parms: event['pathParameters'],
      qs_parms: event['queryStringParameters'],
      body: body,
      event: event,
    }.to_json
  }
end

def return_response(key, value)
  {
    statusCode: 200,
    body: {
      key.to_sym => value,
    }.to_json
  }
end

def bad_request(message = 'Bad Request')
  {
    statusCode: 400,
    body: {
      message: message
    }.to_json
  }
end
