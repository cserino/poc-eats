require_relative '../bootstrap'

class ApplicationHandler
  def return_response(key, value)
    {
      statusCode: 200,
      body: {
        key.to_sym => value,
      }.to_json
    }
  end

  def bad_request(message = 'Bad Request', code: 400)
    {
      statusCode: code,
      body: {
        message: message
      }.to_json
    }
  end
end