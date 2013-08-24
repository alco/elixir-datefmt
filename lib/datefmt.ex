defmodule DateFmt do
  @moduledoc """
  Date formatting and parsing.

  This module provides an interface and core implementation for converting date
  values into strings (formatting) or the other way around (parsing) according
  to the specified template.

  Multiple template formats are supported, each one provided by a separate
  module. One can also implement a custom formatters for use with this module.
  """

  @type formatter :: atom | {function, String.t}

  @doc """
  Converts date values to strings according to the given template (aka format string).
  """
  @spec format(Date.dtz, String.t) :: {:ok, String.t} | {:error, String.t}

  def format(date, fmt) when is_binary(fmt) do
    format(date, fmt, :default)
  end

  @doc """
  Same as `format/2`, but allows to specify a custom formatter to use.
  """
  @spec format(Date.dtz, String.t, formatter) :: {:ok, String.t} | {:error, String.t}

  def format(date, fmt, formatter) when is_binary(fmt) do
    case tokenize(fmt, formatter) do
      { :ok, parts } ->
        Enum.reduce(parts, [], fn
          ({:subfmt, sfmt}, acc) ->
            { :ok, bin } = if is_atom(sfmt) do
              format_predefined(date, sfmt)
            else
              format(date, sfmt, formatter)
            end
            [acc, bin]

          ({dir, fmt}, acc) ->
            arg = format_directive(date, dir)
            [acc, :io_lib.format(fmt, [arg])]

          (bin, acc) when is_binary(bin) ->
            [acc, bin]
        end) |> String.from_char_list

      error -> error
    end
  end

  @doc """
  Raising version of `format/2`. Returns a string with formatted date or
  raises an `ArgumentError`.
  """
  @spec format!(Date.dtz, String.t) :: String.t | no_return

  def format!(date, fmt) do
    format!(date, fmt, :default)
  end

  @doc """
  Raising version of `format/3`. Returns a string with formatted date or
  raises an `ArgumentError`.
  """
  @spec format!(Date.dtz, String.t, formatter) :: String.t | no_return

  def format!(date, fmt, formatter) do
    case format(date, fmt, formatter) do
      { :ok, result } -> result
      { :error, reason } -> raise ArgumentError, message: "Bad format: #{reason}"
    end
  end

  @doc """
  Parses the date encoded in `string` according to the given format.
  """
  @spec parse(String.t, String.t) :: {:ok, Date.dtz} | {:error, String.t}

  def parse(string, fmt) do
    parse(string, fmt, :default)
  end

  @doc """
  Parses the date encoded in `string` according to the given format.
  """
  @spec parse(String.t, String.t, formatter) :: {:ok, Date.dtz} | {:error, String.t}

  def parse(string, fmt, formatter) do
    IO.puts "#{string} #{fmt}"
  end

  @doc """
  Verifies the validity of the given format string. The default formatter is assumed.

  Returns `:ok` if the format string is clean, `{ :error, <reason> }`
  otherwise.
  """
  @spec validate(String.t) :: :ok | {:error, String.t}

  def validate(fmt) do
    validate(fmt, :default)
  end

  @doc """
  Verifies the validity of the given format string.

  Returns `:ok` if the format string is clean, `{ :error, <reason> }`
  otherwise.
  """
  @spec validate(String.t, formatter) :: :ok | {:error, String.t}

  def validate(fmt, formatter) do
    case tokenize(fmt, formatter) do
      { :ok, _ } -> :ok
      error -> error
    end
  end

  #########################
  ### Private functions ###

  defp format_directive(date, dir) do
    {{year,month,day}, {hour,min,sec}} = Date.local(date)

    start_of_year = Date.from({year,1,1})
    {iso_year, iso_week} = Date.iso_weeknum(date)

    daynum = fn date ->
      local = Date.local(date)
      1 + Date.diff(start_of_year, Date.from(local), :day)
    end

    get_week_no = fn jan1weekday ->
      first_monday = rem(7 - jan1weekday, 7) + 1
      div(Date.daynum(date) - first_monday + 7, 7)
    end

    case dir do
      :year      -> year
      :year2     -> rem(year, 100)
      :century   -> div(year, 100)
      :iso_year  -> iso_year
      :iso_year2 -> rem(iso_year, 100)

      :month     -> month
      :mshort    -> month_name_short(month)
      :mfull     -> month_name_full(month)

      :day       -> day
      :oday      -> daynum.(date)
      :wday_mon  -> Date.weekday(date)
      :wday_sun  -> rem(Date.weekday(date), 7)
      :wdshort   -> weekday_name_short(Date.weekday(date))
      :wdfull    -> weekday_name_full(Date.weekday(date))

      :iso_week  -> iso_week
      :week_mon  -> get_week_no.(Date.weekday(start_of_year) - 1)
      :week_sun  -> get_week_no.(rem Date.weekday(start_of_year), 7)

      :hour24    -> hour
      :hour12 when hour in [0, 12] -> 12
      :hour12    -> rem(hour, 12)
      :min       -> min
      :sec       -> sec
      :sec_epoch -> Date.to_sec(date)
      :am        -> if hour < 12 do "am" else "pm" end
      :AM        -> if hour < 12 do "AM" else "PM" end

      :zname ->
        {_,_,{_,tz_name}} = Date.Conversions.to_gregorian(date)
        tz_name
      :zoffs ->
        {_,_,{tz_offset,_}} = Date.Conversions.to_gregorian(date)
        { sign, hour, min, _ } = split_tz(tz_offset)
        :io_lib.format("~s~2..0B~2..0B", [sign, hour, min])
      :zoffs_colon ->
        {_,_,{tz_offset,_}} = Date.Conversions.to_gregorian(date)
        { sign, hour, min, _ } = split_tz(tz_offset)
        :io_lib.format("~s~2..0B:~2..0B", [sign, hour, min])
      :zoffs_sec ->
        {_,_,{tz_offset,_}} = Date.Conversions.to_gregorian(date)
        :io_lib.format("~s~2..0B:~2..0B:~2..0B", tuple_to_list(split_tz(tz_offset)))
    end
  end

  ## ISO 8601 ##

  defp format_predefined(date, :"ISOz") do
    format_iso(Date.universal(date), "Z")
  end

  defp format_predefined(date, :"ISO") do
    # Need to use local time to comply with ISO
    local = Date.local(date)

    { _, _, {offset,_} } = Date.Conversions.to_gregorian(date)

    { sign, hrs, min, _ } = split_tz(offset)
    tz = :io_lib.format("~s~2..0B~2..0B", [sign, hrs, min])

    format_iso(local, tz)
  end

  defp format_predefined(date, :"ISOdate") do
    {{year,month,day}, _} = Date.universal(date)
    :io_lib.format("~4..0B-~2..0B-~2..0B", [year, month, day])
    |> wrap
  end

  defp format_predefined(date, :"ISOtime") do
    {_, {hour,min,sec}} = Date.universal(date)
    :io_lib.format("~2..0B:~2..0B:~2..0B", [hour, min, sec])
    |> wrap
  end

  defp format_predefined(date, :"ISOweek") do
    {year, week} = Date.iso_weeknum(date)
    :io_lib.format("~4..0B-W~2..0B", [year, week])
    |> wrap
  end

  defp format_predefined(date, :"ISOweek-day") do
    {year, week, day} = Date.iso_triplet(date)
    :io_lib.format("~4..0B-W~2..0B-~B", [year, week, day])
    |> wrap
  end

  defp format_predefined(date, :"ISOord") do
    {{year,_,_},_} = Date.universal(date)
    day_no = Date.daynum(date)
    :io_lib.format("~4..0B-~3..0B", [year, day_no])
    |> wrap
  end

  ## RFC 1123 ##

  defp format_predefined(date, :"RFC1123") do
    local = Date.local(date)
    { _, _, {_,tz_name} } = Date.Conversions.to_gregorian(date)
    format_rfc(local, {:name, tz_name})
  end

  defp format_predefined(date, :"RFC1123z") do
    local = Date.local(date)
    { _, _, {tz_offset,_} } = Date.Conversions.to_gregorian(date)
    format_rfc(local, {:offset, tz_offset})
  end

  ## Other common formats ##

  # This is similar to ISO, but using xx:xx format for time zone offset (as
  # opposed to xxxx)
  defp format_predefined(date, :"RFC3339") do
    local = Date.local(date)

    { _, _, {offset,_} } = Date.Conversions.to_gregorian(date)
    tz = if offset == 0 do
      "Z"
    else
      { sign, hrs, min, _ } = split_tz(offset)
      :io_lib.format("~s~2..0B:~2..0B", [sign, hrs, min])
    end
    format_iso(local, tz)
  end

  #ANSIC       = "Mon Jan _2 15:04:05 2006"
  defp format_predefined(date, :"ANSIC") do
    { {year,month,day}, {hour,min,sec} } = Date.local(date)
    day_name = weekday_name_short(Date.weekday(date))
    month_name = month_name_short(month)

    fstr = "~s ~s ~2.. B ~2..0B:~2..0B:~2..0B ~4..0B"
    :io_lib.format(fstr, [day_name, month_name, day, hour, min, sec, year])
    |> wrap
  end

  #UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
  defp format_predefined(date, :"UNIX") do
    { {year,month,day}, {hour,min,sec} } = Date.local(date)
    day_name = weekday_name_short(Date.weekday(date))
    month_name = month_name_short(month)

    {_,_,{_,tz_name}} = Date.Conversions.to_gregorian(date)

    fstr = "~s ~s ~2.. B ~2..0B:~2..0B:~2..0B #{tz_name} ~4..0B"
    :io_lib.format(fstr, [day_name, month_name, day, hour, min, sec, year])
    |> wrap
  end

  #Kitchen     = "3:04PM"
  defp format_predefined(date, :"kitchen") do
    { _, {hour,min,_} } = Date.local(date)
    am = if hour < 12 do "AM" else "PM" end
    hour = if hour in [0, 12] do 12 else rem(hour, 12) end
    :io_lib.format("~B:~2..0B~s", [hour, min, am])
    |> wrap
  end

  #####

  defp format_iso({{year,month,day}, {hour,min,sec}}, tz) do
    :io_lib.format(
        "~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0B~s",
        [year, month, day, hour, min, sec, tz]
    ) |> wrap
  end

  defp format_rfc(date, tz) do
    { {year,month,day}, {hour,min,sec} } = date
    day_name = weekday_name_short(Date.weekday(date))
    month_name = month_name_short(month)
    fstr = case tz do
      { :name, tz_name } ->
        if tz_name == "UTC" do
          tz_name = "GMT"
        end
        "~s, ~2..0B ~s ~4..0B ~2..0B:~2..0B:~2..0B #{tz_name}"
      { :offset, tz_offset } ->
        { sign, tz_hrs, tz_min, _ } = split_tz(tz_offset)
        tz_spec = :io_lib.format("~s~2..0B~2..0B", [sign, tz_hrs, tz_min])
        "~s, ~2..0B ~s ~4..0B ~2..0B:~2..0B:~2..0B #{tz_spec}"
    end
    :io_lib.format(fstr, [day_name, day, month_name, year, hour, min, sec])
    |> wrap
  end

  defp weekday_name_short(day) when day in 1..7 do
    case day do
      1 -> "Mon"; 2 -> "Tue"; 3 -> "Wed"; 4 -> "Thu";
      5 -> "Fri"; 6 -> "Sat"; 7 -> "Sun"
    end
  end

  defp weekday_name_full(day) when day in 1..7 do
    case day do
      1 -> "Monday"; 2 -> "Tuesday"; 3 -> "Wednesday"; 4 -> "Thursday";
      5 -> "Friday"; 6 -> "Saturday"; 7 -> "Sunday"
    end
  end

  defp month_name_short(month) when month in 1..12 do
    case month do
      1 -> "Jan";  2 -> "Feb";  3 -> "Mar";  4 -> "Apr";
      5 -> "May";  6 -> "Jun";  7 -> "Jul";  8 -> "Aug";
      9 -> "Sep"; 10 -> "Oct"; 11 -> "Nov"; 12 -> "Dec"
    end
  end

  defp month_name_full(month) when month in 1..12 do
    case month do
      1 -> "January";    2 -> "February";  3 -> "March";     4 -> "April";
      5 -> "May";        6 -> "June";      7 -> "July";      8 -> "August";
      9 -> "September"; 10 -> "October";  11 -> "November"; 12 -> "December"
    end
  end

  defp split_tz(offset) do
    sign = if offset >= 0 do "+" else "-" end
    offset = abs(offset)
    hrs = trunc(offset)
    min = trunc((offset - hrs) * 60)
    sec = trunc((offset - hrs - min) * 3600)
    { sign, hrs, min, sec }
  end

  defp wrap(formatted) do
    { :ok, iolist_to_binary(formatted) }
  end

  ######################################################

  defp tokenize(fmt, :default) when is_binary(fmt) do
    do_tokenize(fmt, {&DateFmt.Default.process_directive/1, "{"})
  end

  defp tokenize(fmt, :strftime) when is_binary(fmt) do
    do_tokenize(fmt, {&DateFmt.Strftime.process_directive/1, "%"})
  end

  defp tokenize(fmt, {formatter, pat})
        when is_binary(fmt)
         and is_function(formatter)
         and is_binary(pat) do
    do_tokenize(fmt, {formatter, pat})
  end

  defp do_tokenize(str, formatter) do
    do_tokenize(str, formatter, 0, [], [])
  end

  defp do_tokenize("", _, _, parts, acc) do
    { :ok, List.flatten([parts, String.from_char_list!(acc)]) }
  end

  defp do_tokenize(str, {formatter, pat}=fmt, pos, parts, acc) do
    patsize = size(pat)
    case str do
      <<^pat :: [binary, size(patsize)], rest :: binary>> ->
        case formatter.(rest) do
          { :skip, length } ->
            <<skip :: [binary, size(length)], rest :: binary>> = rest
            do_tokenize(rest, fmt, pos + length + 1, parts, [acc,skip])

          { :ok, dir, length } ->
            new_parts = [parts, String.from_char_list!(acc), dir]
            <<_ :: [binary, size(length)], rest :: binary>> = rest
            do_tokenize(rest, fmt, pos + length, new_parts, [])

          { :error, reason } ->
            { :error, "at #{pos}: #{reason}" }
        end
      _ ->
        <<c :: utf8, rest :: binary>> = str
        do_tokenize(rest, fmt, pos+1, parts, [acc, c])
    end
  end
end
