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
    | :iso_local
    | :iso_full
    | :iso_date
    | :iso_time
    | :iso_week
    | :iso_week_day
    | :iso_ordinal
    | :rfc1123
    | :rfc1123z)
  :: {:ok, String.t} | {:error, String.t}

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

  @spec format(Date.dtz, String.t) :: {:ok, String.t} | {:error, String.t}

  def format(date, fmt) do
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
