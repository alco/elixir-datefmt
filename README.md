Date formatting
===============

Implementation of date formatting and parsing for Elixir. This is still work in progress, not everything is ready.

## Status

As of today (Aug 23, 2013) formatting is implemented, with support for two different formatting syntaxes. See moduledocs for `DateFmt.Default` and `DateFmt.Strftime`. Parsing is not implemented yet.

This project depends on the master branch of [elixir-datetime][1], the latter being a general-purpose library that implements all aspects of working with dates and times. Both elixir-datefmt and elixir-datetime will be changing in some places in the coming weeks, but the overall API is going to remain as is.

This is not suitable for use in production. However, early adopters are encourages to give it a try and report any issues to the tracker here on GitHub.

  [1]: https://github.com/alco/elixir-datetime#status
