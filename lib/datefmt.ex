# Don't worry, we will support a few flavours of formatting language.
# * strftime
# * Go's style
# * my own format
# * user-defined format languages

defmodule DateFmt.Default do
  def tokenize(fmt) do
    tokenize(fmt, 0, [], [])
  end

  defp tokenize("", _, parts, acc) do
    { :ok, List.flatten([parts, String.from_char_list!(acc)]) }
  end

  defp tokenize("{{" <> rest, pos, parts, acc) do
    tokenize(rest, pos+2, parts, [acc, "{{"])
  end

  defp tokenize("}}" <> rest, pos, parts, acc) do
    tokenize(rest, pos+2, parts, [acc, "}}"])
  end

  defp tokenize("{" <> rest, pos, parts, acc) do
    case get_flag(rest, []) do
      { flag, rest } ->
        case validate_flag(flag) do
          {_,_}=new_flag ->
            new_parts = [parts, String.from_char_list!(acc), new_flag]
            tokenize(rest, pos + size(flag), new_parts, [])
          :error ->
            { :error, "bad flag at #{pos+1}" }
        end
      :error -> { :error, "missing } (starting at #{pos})" }
    end
  end

  defp tokenize("}" <> _, pos, _, _) do
    { :error, "extraneous } at #{pos}" }
  end

  defp tokenize(<<c :: utf8, rest :: binary>>, pos, parts, acc) do
    tokenize(rest, pos+1, parts, [acc, c])
  end

  defp get_flag("}" <> rest, acc) do
    { iolist_to_binary(acc), rest }
  end

  defp get_flag("", _) do
    :error
  end

  defp get_flag(<<c :: utf8, rest :: binary>>, acc) do
    get_flag(rest, [acc, c])
  end

  defp validate_flag("0" <> flag) do
    do_validate_flag(flag, "0")
  end

  defp validate_flag("_" <> flag) do
    do_validate_flag(flag, " ")
  end

  defp validate_flag(flag) do
    do_validate_flag(flag, nil)
  end

  defp do_validate_flag(flag, nil)
        when flag in ["Mshort", "Mfull",
                      "WDshort", "WDfull",
                      "am", "AM",
                      "ZZZZ", "ZZ:ZZ"] do
    do_convert_flag(flag)
  end

  defp do_validate_flag(flag, modifier)
        when flag in ["YYYY", "YY", "M", "D", "Dord",
                      "WYYYY", "WYY", "Wiso", "Wsun", "Wmon",
                      "WDmon", "WDsun",
                      "h24", "h12", "m", "s"] do
    do_convert_flag(flag, modifier)
  end

  defp do_validate_flag(_, _), do: :error

  def do_convert_flag(flag) do
    tag = case flag do
      "Mshort"  -> :mshort
      "Mfull"   -> :mfull
      "WDshort" -> :wdshort
      "WDfull"  -> :wdfull
      "am"      -> :am
      "AM"      -> :AM
      "ZZZZ"    -> nil
      "ZZ:ZZ"   -> nil
    end
    { tag, "~s" }
  end

  def do_convert_flag(flag, mod) do
    { tag, width } = case flag do
      "YYYY"  -> { :year,      4 }
      "YY"    -> { :year2,     2 }
      "M"     -> { :month,     2 }
      "D"     -> { :day,       2 }
      "Dord"  -> { :oday,      3 }
      "WDmon" -> { :wday,      1 }
      "WDsun" -> { :wday0,     1 }
      "WYYYY" -> { :iso_year,  4 }
      "WYY"   -> { :iso_year2, 2 }
      "Wiso"  -> { :iso_week,  2 }
      "Wsun"  -> { :week_sun,  2 }
      "Wmon"  -> { :week_mon,  2 }
      "h24"   -> { :hour24,    2 }
      "h12"   -> { :hour12,    2 }
      "m"     -> { :minute,    2 }
      "s"     -> { :second,    2 }
    end
    { tag, mod && "~#{width}..#{mod}B" || "~B" }
  end
end

defmodule DateFmt do

  defp wrap(formatted) do
    { :ok, iolist_to_binary(formatted) }
  end

  defp format_iso({{year,month,day}, {hour,min,sec}}, tz) do
    :io_lib.format(
        "~4.10.0B-~2.10.0B-~2.10.0BT~2.10.0B:~2.10.0B:~2.10.0B~s",
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
        sign = if tz_offset >= 0 do "+" else "-" end
        tz_offset = abs(tz_offset)
        tz_hrs = trunc(tz_offset)
        tz_min = trunc((tz_offset - tz_hrs) * 60)
        tz_spec = :io_lib.format("~s~2..0B~2..0B", [sign, tz_hrs, tz_min])
        "~s, ~2..0B ~s ~4..0B ~2..0B:~2..0B:~2..0B #{tz_spec}"
    end
    :io_lib.format(fstr, [day_name, day, month_name, year, hour, min, sec])
    |> wrap
  end

   #                                                             #
  ### Shortcut and efficient implementations for common formats ###
   #                                                             #

  ## ISO 8601 ##

  def format(date, :iso) do
    format_iso(Date.universal(date), "Z")
  end

  def format(date, :iso_local) do
   format_iso(Date.local(date), "")
  end

  def format(date, :iso_full) do
    # Need to use local time to comply with ISO
    local = Date.local(date)

    { _, _, {offset,_} } = Date.Conversions.to_gregorian(date)

    abs_offs = abs(offset)
    hour_offs = trunc(abs_offs)
    min_offs = round((abs_offs - hour_offs) * 60)

    sign = if offset >= 0 do "+" else "-" end
    tz = :io_lib.format("~s~2..0B~2..0B", [sign, hour_offs, min_offs])

    format_iso(local, tz)
  end

  def format(date, :iso_date) do
    {{year,month,day}, _} = Date.universal(date)
    :io_lib.format("~4.10.0B-~2.10.0B-~2.10.0B", [year, month, day])
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

    start_of_year = Date.set(date, [month: 1, day: 1])
    day_no = 1 + Date.diff(start_of_year, date, :day)

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


   #                      #
  ### Generic formatting ###
   #                      #

  def format(date, fmt) when is_binary(fmt) do
    case tokenize(fmt) do
      { :ok, parts } ->
        {{year,month,day}, {hour,min,sec}} = Date.local(date)

        start_of_year = Date.set(date, [month: 1, day: 1])
        day_no = 1 + Date.diff(start_of_year, date, :day)
        {iso_year, iso_week} = Date.weeknum(date)

        get_week_no = fn jan1weekday ->
          first_monday = rem(7 - jan1weekday, 7) + 1
          div(day_no - first_monday + 7, 7)
        end

        Enum.reduce(parts, [], fn
          ({flag, fmt}, acc) ->
            arg = case flag do
              :year      -> year
              :year2     -> rem(year, 100)
              :month     -> month
              :day       -> day
              :oday      -> day_no
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
              :am     -> if hour < 12 do "am" else "pm" end
              :AM     -> if hour < 12 do "AM" else "PM" end
            end
            [acc, :io_lib.format(fmt, [arg])]

          (bin, acc) when is_binary(bin) ->
            [acc, bin]
        end) |> String.from_char_list

      error -> error
    end
  end

  def format!(date, fmt) do
    case format(date, fmt) do
      { :ok, result } -> result
      { :error, reason } -> raise ArgumentError, message: "Bad format: #{reason}"
    end
  end

  def parse(date, fmt) do
    IO.puts "#{date} #{fmt}"
  end

  def validate(fmt) do
    case tokenize(fmt) do
      { :ok, _ } -> :ok
      error -> error
    end
  end

  defp tokenize(fmt) when is_binary(fmt) do
    # Use the default formatter
    DateFmt.Default.tokenize(fmt)
  end

  defp tokenize({:default, fmt}) when is_binary(fmt) do
    # Use the default formatter
    DateFmt.Default.tokenize(fmt)
  end

  defp tokenize({formatter, fmt}) when is_function(formatter) and is_binary(fmt) do
    formatter.(fmt)
  end
end
