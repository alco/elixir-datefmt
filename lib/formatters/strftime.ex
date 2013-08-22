defmodule DateFmt.Strftime do
  defrecordp :directive, dir: nil, flag: nil, width: 0

  def tokenize(fmt) when is_binary(fmt) do
    tokenize(fmt, 0, [], [])
  end

  defp tokenize("", _, parts, acc) do
    { :ok, List.flatten([parts, String.from_char_list!(acc)]) }
  end

  defp tokenize("%%" <> rest, pos, parts, acc) do
    tokenize(rest, pos+2, parts, [acc, "%"])
  end

  defp tokenize("%" <> rest, pos, parts, acc) do
    case get_directive(rest) do
      { dir, rest } ->
        case parse_directive(dir) do
          {_,_}=spec ->
            new_parts = [parts, String.from_char_list!(acc), spec]
            tokenize(rest, pos + size(dir), new_parts, [])
          :error ->
            { :error, "bad directive at #{pos+1}" }
        end
      :error -> { :error, "missing } (starting at #{pos})" }
    end
  end

  defp tokenize(<<c :: utf8>> <> rest, pos, parts, acc) do
    tokenize(rest, pos+1, parts, [acc, c])
  end

  defp get_directive(text) do
    get_directive_flag(text, directive())
  end

  defp get_directive_flag("::" <> rest, dir) do
    get_directive_width(rest, directive(dir, flag: "::"))
  end

  defp get_directive_flag(<<flag :: utf8, rest :: binary>>=str, dir) do
    if flag in [?-, ?_, ?0, ?^, ?#, ?:] do
      dir = directive(dir, flag: flag)
    else
      rest = str
    end
    get_directive_width(rest, dir)
  end

  defp get_directive_width(<<digit :: utf8, rest :: binary>>=str, directive(width: width)=dir) do
    if digit in ?0..?9 do
      dir = directive(dir, width: width * 10 + digit - ?0)
      get_directive_width(rest, dir)
    else
      get_directive_mod(str, dir)
    end
  end

  defp get_directive_mod(<<mod :: utf8>> <> rest, dir)
        when mod in [?E, ?O] do
    # ignore those modifiers
    get_directive_final(rest, dir)
  end

  defp get_directive_mod(other, dir) do
    get_directive_final(other, dir)
  end

  defp get_directive_final(<<char :: utf8>> <> rest, dir) do
    { directive(dir, dir: char), rest }
  end

  defp parse_directive(directive(flag: flag, width: width, dir: dir)) do
    val = case dir do
      ?Y -> { :year,  4 }
      ?y -> { :year2, 2 }
      ?m -> { :month, 2 }
      ?B -> :mfull
      ?b -> :mshort
      ?d -> { :day,   2 }
      ?e -> { :day,   2 }
      ?j -> { :oday,  3 }
      ?H -> { :hour24,  2 }
      ?k -> { :hour24,  2 }
      ?I -> { :hour12,  2 }
      ?l -> { :hour12,  2 }
      ?P -> :am
      ?p -> :AM
      ?M -> { :minute, 2 }
      ?S -> { :second, 2 }
      ?A -> :wdfull
      ?a -> :wdshort
      ?u -> { :wday, 1 }
      ?w -> { :wday0, 1 }
      ?G -> { :iso_year, 4 }
      ?g -> { :iso_year2, 2 }
      ?V -> { :iso_week, 2 }
      ?U -> { :week_sun, 2 }
      ?W -> { :week_mon, 2 }
      ?z -> :zoffs
      ?Z -> :zname
    end

    case val do
      { tag, w } ->
        width = max(w, width)

        pad = if !flag and dir in [?k, ?l] do
          " "
        else
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
