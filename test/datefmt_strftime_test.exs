defmodule DateFmtTest.Strftime do
  use ExUnit.Case, async: true

  test :format_year do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,18})

    assert { :ok, "a2013b" } = format(date, "a%Yb")

    assert { :ok, "a3b" } = format(old_date, "a%-Yb")
    assert { :ok, "a0003b" } = format(old_date, "a%Yb")
    assert { :ok, "a0003b" } = format(old_date, "a%0Yb")
    assert { :ok, "a   3b" } = format(old_date, "a%_Yb")
    assert { :ok, "a3b" }  = format(old_date, "a%-yb")
    assert { :ok, "a03b" } = format(old_date, "a%yb")
    assert { :ok, "a03b" } = format(old_date, "a%0yb")
    assert { :ok, "a 3b" } = format(old_date, "a%_yb")
  end

  test :validate do
    assert :ok = validate ""
    assert :ok = validate "abc"
    assert :ok = validate "Use {{ as oft%%%%en as you like{{"
    assert :ok = validate "%%Same go}}es for }}%%"

    #assert {:error, "missing } (starting at 0)"} = validate "{"
    #assert {:error, "missing } (starting at 4)"} = validate "abc { def"
    #assert {:error, "extraneous } at 4"} = validate "abc } def"
  end

  test :tokenize_bins do
    assert {:ok,[""]} = tokenize ""
    assert {:ok,["abc"]} = tokenize "abc"
    assert {:ok,["Use {{ as oft%%en as you like{{"]} = tokenize "Use {{ as oft%%%%en as you like{{"
    assert {:ok,["%Same go}es for }%"]} = tokenize "%%Same go}es for }%%"
  end

  defp format(date, fmt) do
    DateFmt.format(date, {:strftime, fmt})
  end

  defp validate(fmt) do
    DateFmt.validate({:strftime, fmt})
  end

  defp tokenize(fmt) do
    DateFmt.Strftime.tokenize(fmt)
  end
end
