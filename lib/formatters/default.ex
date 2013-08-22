defmodule DateFmt.Default do
  @moduledoc """
  Date formatting language used by default in the `DateFmt` module.

  This is a novel formatting language introduced with `DateFmt`. Its main
  advantage is simplicity and usage of mnemonics that are easy to memorize.

  ## Directive format

  ## List of all directives
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
                     "WDshort", "WDfull",
                     "am", "AM",
                     "ZZZZ", "ZZ:ZZ"] do
   { :ok, translate_directive(dir) }
  end

  defp parse_directive(dir, modifier)
        when dir in ["YYYY", "YY", "M", "D", "Dord",
                      "WYYYY", "WYY", "Wiso", "Wsun", "Wmon",
                      "WDmon", "WDsun",
                      "h24", "h12", "m", "s"] do
    { :ok, translate_directive(dir, modifier) }
  end

  defp parse_directive(_, _), do: { :error, "bad directive" }

  defp translate_directive(dir) do
    tag = case dir do
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

  defp translate_directive(dir, mod) do
    { tag, width } = case dir do
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
