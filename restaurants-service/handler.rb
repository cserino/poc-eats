

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
