routemaster_blackhole
=====================

A Routemaster subscriber that gobbles events

Subscriptions to one or more topics should be done via the routemaster-client CLI

Once a subscription is active events will be logged to stderr

This application also provides the ability to push events to [data-sink](https://github.com/deliveroo/data-sink). Please
see next section

# Logging received events through DataSink

In order to enable logging received events, [data-sink](https://github.com/deliveroo/data-sink) must be set up
and *all* the following ENV vars need to be set:

- DATASINK_ENABLED (defaults to '0', '1' to activate this logging functionality)
- DATASINK_PASSWORD 
- DATASINK_URL
- DATASINK_USER
- DATASINK_STREAM
