defmodule DateFmt do
  def format(date, fmt) do
    case do_validate(fmt) do
      { :ok, parts } ->
        {{year,_month,_day}, {_hour,_min,_sec}} = Date.local(date)
        output = Enum.reduce(parts, [], fn
          ({:YYYY, mod}, acc) ->
            [acc, mod && :io_lib.format("~4..#{mod}B", [year]) || "#{year}"]

          ({:YY, mod}, acc) ->
            y = rem year, 100
            [acc, mod && :io_lib.format("~2..#{mod}B", [y]) || "#{y}"]

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
    case do_validate(fmt) do
      { :ok, _ } -> :ok
      error -> error
    end
  end

  @doc false
  def do_validate(fmt) do
    do_validate(fmt, 0, [], [])
  end

  defp do_validate("", _, parts, acc) do
    { :ok, List.flatten([parts, String.from_char_list!(acc)]) }
  end

  defp do_validate("{{" <> rest, pos, parts, acc) do
    do_validate(rest, pos+2, parts, [acc, "{{"])
  end

  defp do_validate("}}" <> rest, pos, parts, acc) do
    do_validate(rest, pos+2, parts, [acc, "}}"])
  end

  defp do_validate("{" <> rest, pos, parts, acc) do
    case get_flag(rest, []) do
      { flag, rest } ->
        case validate_flag(flag) do
          {_,_}=new_flag ->
            new_parts = [parts, String.from_char_list!(acc), new_flag]
            do_validate(rest, pos + size(flag), new_parts, [])
          :error ->
            { :error, "bad flag at #{pos+1}" }
        end
      :error -> { :error, "missing } (starting at #{pos})" }
    end
  end

  defp do_validate("}" <> _, pos, _, _) do
    { :error, "extraneous } at #{pos}" }
  end

  defp do_validate(<<c :: utf8, rest :: binary>>, pos, parts, acc) do
    do_validate(rest, pos+1, parts, [acc, c])
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
    { binary_to_atom(flag), nil }
  end

  defp do_validate_flag(flag, modifier)
        when flag in ["YYYY", "YY", "M",
                      "D", "Dord0", "Dord1",
                      "W0", "W1",
                      "h24", "h12", "m", "s"] do
    { binary_to_atom(flag), modifier }
  end

  defp do_validate_flag(_, _), do: :error
end
