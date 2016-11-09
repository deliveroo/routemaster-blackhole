require 'rubygems'
require 'bundler/setup'
require 'routemaster/client'
require 'routemaster/receiver'
require 'dotenv'
require 'sinatra'
require 'pry'

Dotenv.load!

subscriptions = ENV.fetch('TOPIC_SUBSCRIPTIONS', '').split(',')
if subscriptions.any?
  routemaster = Routemaster::Client.new(
    url: ENV.fetch('ROUTEMASTER_URL'),
    uuid: ENV.fetch('ROUTEMASTER_UUID', 'demo'),
  )

  routemaster.subscribe(
    topics: subscriptions,
    callback: ENV.fetch('CALLBACK_URL'),
    uuid: ENV.fetch('CLIENT_UUID', 'demo'),
    max: 1
  )
end

class Handler
  def on_events(events)
    events.each do |event|
      event.keys.each { |k| event[k.to_sym] = event.delete(k) }
      $stderr.write("%<topic>-12s %<type>-12s %<url>s %<t>s\n" % event)
      $stderr.flush
    end
  end
end

use Routemaster::Receiver, {
  path:    '/events',
  uuid:    ENV.fetch('CLIENT_UUID', 'demo'),
  handler: Handler.new
}

run Sinatra::Base
