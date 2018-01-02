routemaster_blackhole
=====================

A silly Routemaster subscriber that does nothing but gobble events


# Logging received events through DataSink

In order to enable logging received events, this requires first setting up [data-sink](https://github.com/deliveroo/data-sink)
and *all* the following ENV vars:

- DATASINK_ENABLED (defaults to 0, 1 to be active)
- DATASINK_PASSWORD
- DATASINK_URL
- DATASINK_USER
- DATASINK_STREAM
