require 'rubygems'
require 'bundler/setup'
require 'routemaster/receiver'
require 'dotenv'
require 'sinatra'
require 'pry'
require 'data_sink_client'

Dotenv.load!

SUBSCRIBER_NAME = 'routemaster-blackhole'

class Handler
  def on_events(events)
    events.each do |event|
      event.keys.each { |k| event[k.to_sym] = event.delete(k) }
      $stderr.write("%<topic>-12s %<type>-12s %<url>s %<t>s\n" % event)
      $stderr.flush
    end
    send_to_data_sink(events)
  end

  private

  def send_to_data_sink(events)
    return unless data_sink_enabled?
    events.map do |event|
      Thread.new do
        event = event.merge(
          subscriber: SUBSCRIBER_NAME,
          received_at: (Time.now.utc.to_f * 1e3).to_i
        )
        DataSinkClient.instance.post(event)
      end
    end.map(&:join)
  end

  def data_sink_enabled?
    ENV.fetch('DATASINK_ENABLED', '0') == '1'
  end
end

use Routemaster::Receiver, {
  path:    '/events',
  uuid:    ENV.fetch('CLIENT_UUID', 'demo'),
  handler: Handler.new
}

run Sinatra::Base
