defmodule DateFmt.Default do
  @moduledoc """
  Date formatting language used by default in the `DateFmt` module.

  This is a novel formatting language introduced with `DateFmt`. Its main
  advantage is simplicity and usage of mnemonics that are easy to memorize.

  ## Directive format

  A directive is an optional _padding specifier_ followed by a _mnemonic_, both enclosed in braces (`{` and `}`):

      {<pad><mnemonic>}

  Supported padding specifiers:

  * `0` -- pads the number with zeros. Applicable to mnemonics that produce numerical result.
  * `_` -- pads the number with spaces.  Applicable to mnemonics that produce numerical result.

  When padding specifier is omitted, numbers will not be padded.

  ## List of all directives

  ### Years and centuries

  * `{YYYY}`    - full year number (0..9999)
  * `{YY}`      - the last to digits of the year number (0.99)
  * `{C}`       - century number (0..99)
  * `{WYYYY}`   - year number corresponding to the ISO week (0..9999)
  * `{WYY}`     - the last two digits of the ISO week year (0..99)

  ### Months

  * `{M}`       - month number (1..12)
  * `{Mshort}`  - abbreviated month name (Jan..Dec, no padding)
  * `{Mfull}`   - full month name (January..December, no padding)

  ### Days and weekdays

  * `{D}`       - day number (1..31)
  * `{Dord}`    - ordinal day of the year (1..366)
  * `{WDmon}`   - weekday, Monday first (1..7, no padding)
  * `{WDsun}`   - weekday, Sunday first (0..6, no padding)
  * `{WDshort}` - abbreviated weekday name (Mon..Sun, no padding)
  * `{WDfull}`  - full weekday name (Monday..Sunday, no padding)

  ### Weeks

  * `{Wiso}`    - ISO week number (1..53)
  * `{Wmon}`    - week number of the year, Monday first (0..53)
  * `{Wsun}`    - week number of the year, Sunday first (0..53)

  ### Time

  * `{h24}`     - hour of the day (0..23)
  * `{h12}`     - hour of the day (1..12)
  * `{m}`       - minutes of the hour (0..59)
  * `{s}`       - seconds of the minute (0..60)
  * `{sepoch}`  - number of seconds since UNIX epoch
  * `{am}`      - lowercase am or pm (no padding)
  * `{AM}`      - uppercase AM or PM (no padding)

  ### Time zones

  * `{Zname}`   - time zone name, e.g. `UTC` (no padding)
  * `{Z}`       - time zone offset in the form `-0730` (sign is always present, no padding)
  * `{Z:}`      - time zone offset in the form `-07:30`
  * `{Z::}`     - time zone offset in the form `-07:30:00`

  ### Compound directives

  These are shortcut directives corresponding to parts of the ISO 8601 specification.

  * `{ISO}`         -
  * `{ISOutc}`      -
  * `{ISOdate}`     -
  * `{ISOtime}`     -
  * `{ISOweek}`     -
  * `{ISOweek-day}` -
  * `{ISOordinal}`  -

  And the ones below are miscellaneous common formats:

  * `{RFC1123}`  -
  * `{RFC1123z}` -
  * `{RFC3339}`  -
  * `{ANSIC}`    -
  * `{UNIX}`     -
  * `{Kitchen}`  -

  """

  def process_directive("{" <> _) do
    # false alarm
    { :skip, 1 }
  end

  def process_directive(fmt) when is_binary(fmt) do
    case scan_directive(fmt, 0) do
      { :ok, pos } ->
        length = pos-1
        <<dirstr :: [binary, size(length)], _ :: binary>> = fmt
        case parse_directive(dirstr) do
          { :ok, directive } -> { :ok, directive, pos }
          error              -> error
        end

      error -> error
    end
  end

  ###

  defp scan_directive("{" <> _, _) do
    { :error, "extraneous { in directive" }
  end

  defp scan_directive("", _) do
    { :error, "missing }" }
  end

  defp scan_directive("}" <> _, pos) do
    { :ok, pos+1 }
  end

  defp scan_directive(<<_ :: utf8>> <> rest, pos) do
    scan_directive(rest, pos+1)
  end

  ###

  # Sanity check on the modifier
  defp parse_directive("0" <> dir) do
    parse_directive(dir, "0")
  end

  defp parse_directive("_" <> dir) do
    parse_directive(dir, " ")
  end

  defp parse_directive(dir) do
    parse_directive(dir, nil)
  end

  # Actual parsing
  defp parse_directive(dir, nil)
        when dir in ["Mshort", "Mfull",
                     "WDmon", "WDsun", "WDshort", "WDfull",
                     "am", "AM",
                     "Zname", "Z", "Z:", "Z::"] do
   { :ok, translate_directive(dir) }
  end

  defp parse_directive(dir, modifier)
        when dir in ["YYYY", "YY", "C", "WYYYY", "WYY",
                     "M",
                     "D", "Dord",
                     "Wiso", "Wmon", "Wsun",
                     "h24", "h12", "m", "s", "sepoch"] do
    { :ok, translate_directive(dir, modifier) }
  end

  defp parse_directive(_, _), do: { :error, "bad directive" }

  defp translate_directive(dir) do
    tag = case dir do
      "Mshort"  -> :mshort
      "Mfull"   -> :mfull

      "WDmon"   -> :wday_mon
      "WDsun"   -> :wday_sun
      "WDshort" -> :wdshort
      "WDfull"  -> :wdfull

      "am"      -> :am
      "AM"      -> :AM

      "Zname"   -> :zname
      "Z"       -> :zoffs
      "Z:"      -> :zoffs_colon
      "Z::"     -> :zoffs_sec
    end
    { tag, if tag in [:wday_mon, :wday_sun] do "~B" else "~s" end }
  end

  defp translate_directive(dir, mod) do
    { tag, width } = case dir do
      "YYYY"   -> { :year,      4 }
      "YY"     -> { :year2,     2 }
      "C"      -> { :century,   2 }
      "WYYYY"  -> { :iso_year,  4 }
      "WYY"    -> { :iso_year2, 2 }

      "M"      -> { :month,     2 }

      "D"      -> { :day,       2 }
      "Dord"   -> { :oday,      3 }

      "Wiso"   -> { :iso_week,  2 }
      "Wmon"   -> { :week_mon,  2 }
      "Wsun"   -> { :week_sun,  2 }

      "h24"    -> { :hour24,    2 }
      "h12"    -> { :hour12,    2 }
      "m"      -> { :min,       2 }
      "s"      -> { :sec,       2 }
      "sepoch" -> { :sec_epoch, 10 }
    end
    { tag, mod && "~#{width}..#{mod}B" || "~B" }
  end
end
