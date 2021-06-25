load "vendor/bundle/bundler/setup.rb"
$LOAD_PATH.unshift(File.expand_path("./app", __dir__))

require 'platform'
Platform.init_database!

require 'json'
require 'aws-sdk-lambda'
require 'models/order'

def lambda_client(service)
  Aws::Lambda::Client.new(
    endpoint: ENV.fetch(
      "SERVICE_#{service.upcase}_LAMBDA_URL",
      'AWS_LAMBDA_URL',
    )
  )
end

def db_event(event:, context:)
  Platform.handle_database_event(ENV['AWS_LAMBDA_FUNCTION_NAME'], event, context)
end

def create_order(event:, context:)
  payload = JSON.parse(event['body'])
  order = Order.create(payload)

  {
    statusCode: 201,
    body: {
      order: order,
    }.to_json
  }
end

def hello(event:, context:)
  orders = Order.all

  raw_response = lambda_client('restaurants').invoke({
    function_name: 'restaurants-service-dev-hello',
    invocation_type: 'RequestResponse',
    payload: {
      hello: 'true',
    }.to_json,
  })

  payload = JSON.parse(raw_response.payload.string)
  response = JSON.parse(payload['body'])

  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      response: response,
      input: event,
      orders: orders,
    }.to_json
  }
end
