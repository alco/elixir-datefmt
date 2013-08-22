# Don't worry, we will support a few flavours of formatting language.
# * strftime
# * Go's style
# * my own format
# * user-defined format languages

defmodule DateFmt do
   #                                                             #
  ### Shortcut and efficient implementations for common formats ###
   #                                                             #

  @spec format(Date.dtz,
      :iso
    | :iso_full
    | :iso_date
    | :iso_time
    | :iso_week
    | :iso_week_day
    | :iso_ordinal
    | :rfc1123
    | :rfc1123z
    | :rfc3339
    | :ansic
    | :unix
    )
  :: {:ok, String.t} | {:error, String.t}

  ## ISO 8601 ##

  def format(date, :iso) do
    format_iso(Date.universal(date), "Z")
  end

  def format(date, :iso_full) do
    # Need to use local time to comply with ISO
    local = Date.local(date)

    { _, _, {offset,_} } = Date.Conversions.to_gregorian(date)

    { sign, hrs, min, _ } = split_tz(offset)
    tz = :io_lib.format("~s~2..0B~2..0B", [sign, hrs, min])

    format_iso(local, tz)
  end

  def format(date, :iso_date) do
    {{year,month,day}, _} = Date.universal(date)
    :io_lib.format("~4..0B-~2..0B-~2..0B", [year, month, day])
    |> wrap
  end

  def format(date, :iso_time) do
    {_, {hour,min,sec}} = Date.universal(date)
    :io_lib.format("~2..0B:~2..0B:~2..0B", [hour, min, sec])
    |> wrap
  end

  def format(date, :iso_week) do
    {year, week} = Date.weeknum(date)
    :io_lib.format("~4..0B-W~2..0B", [year, week])
    |> wrap
  end

  def format(date, :iso_week_day) do
    {year, week, day} = Date.iso_triplet(date)
    :io_lib.format("~4..0B-W~2..0B-~B", [year, week, day])
    |> wrap
  end

  def format(date, :iso_ordinal) do
    {{year,_,_},_} = Date.universal(date)
    day_no = Date.daynum(date)
    :io_lib.format("~4..0B-~3..0B", [year, day_no])
    |> wrap
  end

  ## RFC 1123 ##

  def format(date, :rfc1123) do
    local = Date.local(date)
    { _, _, {_,tz_name} } = Date.Conversions.to_gregorian(date)
    format_rfc(local, {:name, tz_name})
  end

  def format(date, :rfc1123z) do
    local = Date.local(date)
    { _, _, {tz_offset,_} } = Date.Conversions.to_gregorian(date)
    format_rfc(local, {:offset, tz_offset})
  end

  ## Other common formats ##

  # This is similar to ISO, but using xx:xx format for time zone offset (as
  # opposed to xxxx)
  def format(date, :rfc3339) do
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
  def format(date, :ansic) do
    { {year,month,day}, {hour,min,sec} } = Date.local(date)
    day_name = Date.weekday_name(Date.weekday(date), :short)
    month_name = Date.month_name(month, :short)

    fstr = "~s ~s ~2.. B ~2..0B:~2..0B:~2..0B ~4..0B"
    :io_lib.format(fstr, [day_name, month_name, day, hour, min, sec, year])
    |> wrap
  end

  #UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
  def format(date, :unix) do
    { {year,month,day}, {hour,min,sec} } = Date.local(date)
    day_name = Date.weekday_name(Date.weekday(date), :short)
    month_name = Date.month_name(month, :short)

    {_,_,{_,tz_name}} = Date.Conversions.to_gregorian(date)

    fstr = "~s ~s ~2.. B ~2..0B:~2..0B:~2..0B #{tz_name} ~4..0B"
    :io_lib.format(fstr, [day_name, month_name, day, hour, min, sec, year])
    |> wrap
  end

   #                      #
  ### Generic formatting ###
   #                      #

  @spec format(Date.dtz, String.t) :: {:ok, String.t} | {:error, String.t}

  def format(date, fmt) do
    case tokenize(fmt) do
      { :ok, parts } ->
        {{year,month,day}, {hour,min,sec}} = Date.local(date)

        start_of_year = Date.set(date, [month: 1, day: 1])
        {iso_year, iso_week} = Date.weeknum(date)

        get_week_no = fn jan1weekday ->
          first_monday = rem(7 - jan1weekday, 7) + 1
          div(Date.daynum(date) - first_monday + 7, 7)
        end

        Enum.reduce(parts, [], fn
          ({flag, fmt}, acc) ->
            arg = case flag do
              :year      -> year
              :year2     -> rem(year, 100)
              :month     -> month
              :day       -> day
              :oday      -> Date.daynum(date)
              :wday      -> Date.weekday(date)
              :wday0     -> rem(Date.weekday(date), 7)
              :iso_year  -> iso_year
              :iso_year2 -> rem(iso_year, 100)
              :iso_week  -> iso_week
              :week_sun ->
                get_week_no.(rem Date.weekday(start_of_year), 7)
              :week_mon ->
                get_week_no.(Date.weekday(start_of_year) - 1)
              :hour24 -> hour
              :hour12 when hour in [0, 12] -> 12
              :hour12 -> rem(hour, 12)
              :minute -> min
              :second -> sec
              :mshort ->
                Date.month_name(month, :short)
              :mfull ->
                Date.month_name(month, :full)
              :wdshort ->
                wday = Date.weekday(date)
                Date.weekday_name(wday, :short)
              :wdfull ->
                wday = Date.weekday(date)
                Date.weekday_name(wday, :full)
              :am -> if hour < 12 do "am" else "pm" end
              :AM -> if hour < 12 do "AM" else "PM" end
              :zname ->
                {_,_,{_,tz_name}} = Date.Conversions.to_gregorian(date)
                tz_name
              :zoffs ->
                {_,_,{tz_offset,_}} = Date.Conversions.to_gregorian(date)
                { sign, hrs, min, _ } = split_tz(tz_offset)
                { sign, hrs, min }
              :zoffs_sec ->
                {_,_,{tz_offset,_}} = Date.Conversions.to_gregorian(date)
                split_tz(tz_offset)
            end
            case arg do
              {a, b, c, d} ->
                [acc, :io_lib.format(fmt, [a, b, c, d])]
              {a, b, c} ->
                [acc, :io_lib.format(fmt, [a, b, c])]
              other ->
                [acc, :io_lib.format(fmt, [other])]
            end

          (bin, acc) when is_binary(bin) ->
            [acc, bin]
        end) |> String.from_char_list

      error -> error
    end
  end

  @doc """
  A raising version of `format/2`. Returns a string with formatted date or
  raises an `ArgumentError`.
  """
  def format!(date, fmt) do
    case format(date, fmt) do
      { :ok, result } -> result
      { :error, reason } -> raise ArgumentError, message: "Bad format: #{reason}"
    end
  end

  ####

  defp format_iso({{year,month,day}, {hour,min,sec}}, tz) do
    :io_lib.format(
        "~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0B~s",
        [year, month, day, hour, min, sec, tz]
    ) |> wrap
  end

  defp format_rfc(date, tz) do
    { {year,month,day}, {hour,min,sec} } = date
    day_name = Date.weekday_name(Date.weekday(date), :short)
    month_name = Date.month_name(month, :short)
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

  @doc """
  Parses the date encoded in `string` according to the given format.
  """
  def parse(string, fmt) do
    IO.puts "#{string} #{fmt}"
  end

  ######################################################

  @doc """
  Verfiy the validity of format string. The argument is either a string or
  formatter tuple.

  Returns `:ok` if the format string is clean, `{ :error, <reason> }`
  otherwise.
  """
  def validate(fmt) do
    case tokenize(fmt) do
      { :ok, _ } -> :ok
      error -> error
    end
  end

  ######################################################

  defp tokenize({:default, fmt}) when is_binary(fmt) do
    DateFmt.Default.tokenize(fmt)
  end

  defp tokenize({:strftime, fmt}) when is_binary(fmt) do
    DateFmt.Strftime.tokenize(fmt)
  end

  defp tokenize({formatter, fmt}) when is_function(formatter) and is_binary(fmt) do
    formatter.(fmt)
  end

  defp tokenize(fmt) when is_binary(fmt) do
    tokenize({:default, fmt})
  end
end
