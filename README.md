routemaster_blackhole
=====================

A Routemaster subscriber that gobbles events

Subscriptions to one or more topics should be done via the routemaster-client CLI

```
rtm sub add "https://<routemaster-blackhole-application-url>/events" topic1 topic2 -b <routemaster-url> -t <routemaster-blackhole-drain-token>
```

Once a subscription is active events can now be logged

# Logging received events to stderr

To enable logging of events in the logs set `STDERR_ENABLED` to '1' (defaults to '0')

# Logging received events through DataSink

This application also provides the ability to push events to [data-sink](https://github.com/deliveroo/data-sink)

In order to enable logging received events, [data-sink](https://github.com/deliveroo/data-sink) must be set up
and *all* the following ENV vars need to be set:

- DATASINK_ENABLED (defaults to '0', '1' to activate this logging functionality)
- DATASINK_PASSWORD 
- DATASINK_URL
- DATASINK_USER
- DATASINK_STREAM
