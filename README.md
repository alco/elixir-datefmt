Date formatting
===============

Implementation of date formatting and parsing for Elixir. This is still work in progress, not everything is ready.

## Status

As of today (Aug 23, 2013) formatting is implemented, with support for two different formatting syntaxes. See moduledocs for `DateFmt.Default` and `DateFmt.Strftime`. Parsing is not implemented yet.

This project depends on the master branch of [elixir-datetime][1], the latter being a general-purpose library that implements all aspects of working with dates and times. Both elixir-datefmt and elixir-datetime will be changing in some places in the coming weeks, but the overall API is going to remain as is.

This is not suitable for use in production. However, early adopters are encourages to give it a try and report any issues to the tracker here on GitHub.


## Getting started

To quickly start playing with your formatting language of choice, you can use these functions from the `Date` module (part of [elixir-datetime][1]):

```elixir
date = Date.now()      # get current date and time in the local time zone
date = Date.now(:utc)  # same, but in UTC

# Convert from Erlang date
date = Date.from({year,month,day})
# Convert from Erlang datetime
date = Date.from({ {year,month,day}, {hour,min,sec} })
# Convert from Erlang datetime assuming the given date is in the specified
# time zone
date = Date.from({ {year,month,day}, {hour,min,sec} }, Date.timezone(3.0, "EEST"))

# Now that you have a date value to work with, formatting it is as simple as
DateFmt.format(somedate, "{ANSIC}")
#=> "Tue Mar  5 23:25:19 2013"

DateFmt.format(someotherdate, "{YYYY}-{M}-{D} {WDshort} {h12}:{0m}:{0s} {AM}")
#=> "2013-8-18 Sun 12:03:04 PM"
```

## Writing custom formatters

**TODO**

  [1]: https://github.com/alco/elixir-datetime#status
