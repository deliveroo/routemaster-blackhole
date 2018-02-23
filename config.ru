require 'rubygems'
require 'bundler/setup'
require 'routemaster/client'
require 'routemaster/drain/basic'
require 'dotenv'
require 'sinatra'
require 'pry'
require 'data_sink_client'
require 'concurrent'
require 'newrelic_rpm'

Dotenv.load!

require 'routemaster/middleware/authenticate'

module Routemaster::Middleware
  def _valid_auth?(env)
    user = env['HTTP_AUTHORIZATION'].gsub(/^Basic /, '')
    token = Base64.decode64(user).split(':').first
    puts "user: #{user}, token: #{token}"
    @uuid.include?(token)
  end
end

SUBSCRIBER_NAME = 'routemaster-blackhole'.freeze
DATASINK_CONCURRENCY = ENV.fetch('DATASINK_CONCURRENCY', 10).to_i
DATASINK_CONCURRENCY_OPTIONS = {
  max_queue: ENV.fetch('DATASINK_CONCURRENCY_MAX_QUEUE', 100).to_i,
  fallback_policy: :caller_runs
}.freeze

class ApplicationDrain < Routemaster::Drain::Basic
  def initialize(_)
    super()

    on(:events_received) do |events|
      send_to_stderr(events)    if stderr_enabled?
      send_to_data_sink(events) if data_sink_enabled?
    end
  end

  private

  def send_to_data_sink(events)
    pool        = Concurrent::FixedThreadPool.new(DATASINK_CONCURRENCY, DATASINK_CONCURRENCY_OPTIONS)
    received_at = (Time.now.utc.to_f * 1e3).to_i
    client      = DataSinkClient.new

    events.each do |event|
      pool.post do
        event = event.merge(
          subscriber: SUBSCRIBER_NAME,
          received_at: received_at
        )
        client.post(event.to_h)
      end
    end
    pool.shutdown
    pool.wait_for_termination
  ensure
    pool.shutdown
  end

  def send_to_stderr(events)
    events.each do |event|
      event = event.to_h
      event.keys.each { |k| event[k.to_sym] = event.delete(k) }
      $stderr.write("%<topic>-12s %<type>-12s %<url>s %<t>s\n" % event)
      $stderr.flush
    end
  end

  def stderr_enabled?
    ENV.fetch('STDERR_ENABLED', '0') == '1'
  end

  def data_sink_enabled?
    ENV.fetch('DATASINK_ENABLED', '0') == '1'
  end
end

get '/health' do
  'OK'
end

map '/events' do
  use ApplicationDrain
end

run Sinatra::Application
