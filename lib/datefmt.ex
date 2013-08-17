defmodule DateFmt do
  def format(date, fmt) do
    case do_validate(fmt) do
      { :ok, parts } ->
        # ...
        :ok

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
    { :ok, List.flatten([parts, {:bin, String.from_char_list!(acc)}]) }
  end

  defp do_validate("{{" <> rest, pos, parts, acc) do
    do_validate(rest, pos+2, parts, [acc, "{{"])
  end

  defp do_validate("}}" <> rest, pos, parts, acc) do
    do_validate(rest, pos+2, parts, [acc, "}}"])
  end

  defp do_validate("{" <> rest, pos, parts, acc) do
    case get_flag(rest, [], pos) do
      { :ok, flag, rest } ->
        case validate_flag(flag, pos+1) do
          :ok ->
            new_parts = [parts, {:bin, String.from_char_list!(acc)}, {:flag, flag}]
            do_validate(rest, pos + size(flag), new_parts, [])
          error ->
            error
        end
      error -> error
    end
  end

  defp do_validate("}" <> _, pos, _, _) do
    { :error, "extraneous } at #{pos}" }
  end

  defp do_validate(<<c :: utf8, rest :: binary>>, pos, parts, acc) do
    do_validate(rest, pos+1, parts, [acc, c])
  end

  defp get_flag("}" <> rest, acc, pos) do
    { :ok, iolist_to_binary(acc), rest, pos }
  end

  defp get_flag("", _, pos) do
    { :error, "missing } (starting at #{pos})" }
  end

  defp get_flag(<<c :: utf8, rest :: binary>>, acc, pos) do
    get_flag(rest, [acc, c], pos)
  end

  defp validate_flag(flag, _pos) do
    :ok
  end
end
