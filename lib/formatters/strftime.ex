defmodule DateFmt.Strftime do
  defrecordp :directive, dir: nil, flag: ?0, width: 0

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
    { tag, w } = case dir do
      ?Y -> { :year,  4 }
      ?y -> { :year2, 2 }
      ?m -> { :month, 2 }
      ?d -> { :day,   2 }
      ?e -> { :day,   2 }
      ?j -> { :oday,  3 }
    end

    width = max(w, width)

    pad = case flag do
      ?- -> nil
      ?_ -> " "
      other  -> <<other :: utf8>>
    end


    { tag, pad && "~#{width}..#{pad}B" || "~B" }
  end
end
