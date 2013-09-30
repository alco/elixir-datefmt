Date formatting
===============

Implementation of date formatting and parsing for Elixir. This is still work in progress, not everything is ready.

## Status

This project is open for takeover. If you wish to become a maintainer, please contact me.

---

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
#=> { :ok, "Tue Mar  5 23:25:19 2013" }

DateFmt.format(someotherdate, "{YYYY}-{M}-{D} {WDshort} {h12}:{0m}:{0s} {AM}")
#=> { :ok, "2013-8-18 Sun 12:03:04 PM" }
```

See [formatting](https://github.com/alco/elixir-datefmt/blob/master/test/format_default_test.exs) [tests](https://github.com/alco/elixir-datefmt/blob/master/test/format_strftime_time.exs) for more examples.

## Writing custom formatters

A formatter is defined by a tuple `{ <tokenizing function>, <trigger string> }`. The `<tokenizing function>` is called every time the `<trigger string>` is seen in the template string. The return value needs to be one of the following:

* `{ :skip, <num> }` -- indicates that the scanning of the template string should continue `<num>` characters from the current position;
* `{ :ok, <directive>, <pos> }` -- the `<directive>` is stored by `DateFmt` for later use, and the scanning is resumed at position `<pos>`;
* `{ :error, <reason> }` -- signals that the formatting process should be aborted with the given error.

Any part of the template string located between two formatting directives (or between one directive and the beginning/end of the string) will be copied as is to the output.

Have a look at how default formatters are implemented, referenced [here](https://github.com/alco/elixir-datefmt/blob/master/lib/datefmt.ex#L557)

  [1]: https://github.com/alco/elixir-datetime#status
