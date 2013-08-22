defmodule DateFmt.Default do
  @moduledoc """
  Date formatting language used by default in the `DateFmt` module.

  This is a novel formatting language introduced with `DateFmt`. Its main
  advantage is simplicity and usage of mnemonics that are easy to memorize.

  ## Directive format

  ## List of all directives
  """

  def tokenize(fmt) when is_binary(fmt) do
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
        case parse_flag(flag) do
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

  defp tokenize(<<c :: utf8>> <> rest, pos, parts, acc) do
    tokenize(rest, pos+1, parts, [acc, c])
  end

  defp get_flag("}" <> rest, acc) do
    { iolist_to_binary(acc), rest }
  end

  defp get_flag("", _) do
    :error
  end

  defp get_flag(<<c :: utf8>> <> rest, acc) do
    get_flag(rest, [acc, c])
  end

  defp parse_flag("0" <> flag) do
    do_parse_flag(flag, "0")
  end

  defp parse_flag("_" <> flag) do
    do_parse_flag(flag, " ")
  end

  defp parse_flag(flag) do
    do_parse_flag(flag, nil)
  end

  defp do_parse_flag(flag, nil)
        when flag in ["Mshort", "Mfull",
                      "WDshort", "WDfull",
                      "am", "AM",
                      "ZZZZ", "ZZ:ZZ"] do
    do_convert_flag(flag)
  end

  defp do_parse_flag(flag, modifier)
        when flag in ["YYYY", "YY", "M", "D", "Dord",
                      "WYYYY", "WYY", "Wiso", "Wsun", "Wmon",
                      "WDmon", "WDsun",
                      "h24", "h12", "m", "s"] do
    do_convert_flag(flag, modifier)
  end

  defp do_parse_flag(_, _), do: :error

  defp do_convert_flag(flag) do
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

  defp do_convert_flag(flag, mod) do
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
