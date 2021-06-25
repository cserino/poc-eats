load "vendor/bundle/bundler/setup.rb"
$LOAD_PATH.unshift(File.expand_path("../app", __dir__))

require 'json'

def hello(event:, context:)
  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end
