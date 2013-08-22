defmodule DateFmt.Strftime do
  @moduledoc """
  Date formatting language defined by the `strftime` function from the Standard
  C Library.

  This implementation in Elixir is mostly compatible with `strftime`. The
  exception is the absence of locale-depended results. All directives that imply
  textual result will produce English names and abbreviations.

  A complete reference of the directives implemented here is given below.

  ## Directive format

  ## List of all directives

  ### Years and centuries

  * `%Y` -
  * `%Y` -
  * `%Y` -
  * `%Y` -
  * `%Y` -

  ### Months

  * `%Y` -
  * `%Y` -
  * `%Y` -
  * `%Y` -
  * `%Y` -

  ### Weeks, days, and days of week

  * `%Y` -
  * `%Y` -
  * `%Y` -
  * `%Y` -

  ### Time

  * `%Y` -
  * `%Y` -
  * `%Y` -

  ### Compounds

  * `%Y` -
  * `%Y` -
  * `%Y` -
  """

  defrecordp :directive, dir: nil, flag: nil, width: -1

  def process_directive("%" <> _) do
    # false alarm
    { :skip, 1 }
  end

  def process_directive(fmt) when is_binary(fmt) do
    case scan_directive(fmt, 0) do
      { :ok, dir, length } ->
        case translate_directive(dir) do
          {_,_}=directive -> { :ok, directive, length }
          error              -> error
        end

      error -> error
    end
  end

  ###

  defp scan_directive(str, pos) do
    scan_directive_flag(str, pos, directive())
  end

  ###

  defp scan_directive_flag("::" <> rest, pos, dir) do
    scan_directive_width(rest, pos+2, directive(dir, flag: "::"))
  end

  defp scan_directive_flag(<<flag :: utf8, rest :: binary>>, pos, dir)
        when flag in [?-, ?_, ?0, ?^, ?#, ?:] do
    scan_directive_width(rest, pos+1, directive(dir, flag: flag))
  end

  defp scan_directive_flag(str, pos, dir) do
    scan_directive_width(str, pos, dir)
  end

  ###

  defp scan_directive_width(<<digit :: utf8, rest :: binary>>, pos, directive(width: width)=dir)
        when digit in ?0..?9 do
    new_width = width * 10 + digit - ?0
    scan_directive_width(rest, pos+1, directive(dir, width: new_width))
  end

  defp scan_directive_width(str, pos, dir) do
    scan_directive_modifier(str, pos, dir)
  end

  ###

  defp scan_directive_modifier(<<mod :: utf8>> <> rest, pos, dir)
        when mod in [?E, ?O] do
    # ignore those modifiers
    scan_directive_final(rest, pos+1, dir)
  end

  defp scan_directive_modifier(str, pos, dir) do
    scan_directive_final(str, pos, dir)
  end

  ###

  defp scan_directive_final(<<char :: utf8>> <> _, pos, dir) do
    { :ok, directive(dir, dir: char), pos+1 }
  end

  ###

  defp translate_directive(directive(flag: flag, width: width, dir: dir)) do
    val = case dir do
      ?Y -> { :year,    4 }
      ?y -> { :year2,   2 }
      ?C -> { :century, 2 }
      ?m -> { :month,   2 }
      ?B -> :mfull
      ?b -> :mshort
      ?d -> { :day,     2 }
      ?e -> { :day,     2 }
      ?j -> { :oday,    3 }
      ?H -> { :hour24,  2 }
      ?k -> { :hour24,  2 }
      ?I -> { :hour12,  2 }
      ?l -> { :hour12,  2 }
      ?P -> :am
      ?p -> :AM
      ?M -> { :minute,  2 }
      ?S -> { :second,  2 }
      ?s -> { :nsec,   -1 }
      ?A -> :wdfull
      ?a -> :wdshort
      ?u -> { :wday,      1 }
      ?w -> { :wday0,     1 }
      ?G -> { :iso_year,  4 }
      ?g -> { :iso_year2, 2 }
      ?V -> { :iso_week,  2 }
      ?U -> { :week_sun,  2 }
      ?W -> { :week_mon,  2 }
      ?z -> :zoffs
      ?Z -> :zname

      # combined directives
      ?D -> { :subfmt, "%m/%d/%y" }
      ?F -> { :subfmt, "%Y-%m-%d" }
      ?R -> { :subfmt, "%H:%M" }
      ?r -> { :subfmt, "%I:%M:%S %p" }
      ?T -> { :subfmt, "%H:%M:%S" }
      ?v -> { :subfmt, "%e-%b-%Y" }
    end

    case val do
      { :subfmt, _ }=result -> result

      { tag, w } ->
        width = max(w, width)
        pad = cond do
          width < 0 -> nil
          !flag and dir in [?e, ?k, ?l] -> " "
          true ->
            case flag do
              ?-    -> nil
              ?_    -> " "
              nil   -> "0"
              other -> <<other :: utf8>>
            end
        end

        { tag, pad && "~#{width}..#{pad}B" || "~B" }

      :zoffs ->
        case flag do
          nil  -> { :zoffs, "~s~2..0B~2..0B" }
          ?:   -> { :zoffs, "~s~2..0B:~2..0B" }
          "::" -> { :zoffs_sec, "~s~2..0B:~2..0B:~2..0B" }
          _ -> raise ArgumentError, message: "Invalid flag for %z"
        end

      tag ->
        if nil?(flag) do
          { tag, "~s" }
        else
          raise ArgumentError, message: "Invalid flag for %z"
        end
    end
  end
end
