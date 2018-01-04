require 'oj'
require 'data-sink-client'

class DataSinkClient
  def initialize
    options = {
      user: ENV.fetch('DATASINK_USER'),
      pass: ENV.fetch('DATASINK_PASSWORD'),
      url:  ENV.fetch('DATASINK_URL')
    }

    @client = ::DataSink::Client.new(options)
    @stream = ENV.fetch('DATASINK_STREAM')
  end

  def post(event)
    @client.post(@stream, Oj.dump(event))
  end
end
