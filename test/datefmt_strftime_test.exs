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

  test :format_ordinal_day do
    date = Date.from({3,2,1})

    assert { :ok, "32" } = format(date, "%-j")
    assert { :ok, "032" } = format(date, "%j")
    assert { :ok, " 32" } = format(date, "%_j")

    date = Date.from({3,12,31})
    assert { :ok, "365" } = format(date, "%j")

    date = Date.from({3,1,1})
    assert { :ok, "001" } = format(date, "%j")
    assert { :ok, "001" } = format(date, "%0j")

    date = Date.from({2007,11,19})
    assert { :ok, "2007323" } = format(date, "%Y%j")
    assert { :ok, "2007-323" } = format(date, "%Y-%j")

    date = Date.from({2007,11,18})
    assert { :ok, "0" } = format(date, "%w")
    assert { :ok, "7" } = format(date, "%u")
  end

  test :format_names do
    date = Date.from({2013,1,1})
    assert { :ok, "Tue" } = format(date, "%a")
    assert { :ok, "Tuesday" } = format(date, "%A")

    assert { :ok, "Jan" } = format(date, "%b")
    assert { :ok, "January" } = format(date, "%B")
  end

  test :format_ordinal_week do
    date = Date.from({2013,1,1})
    assert { :ok, "00" } = format(date, "%W")
    assert { :ok, "00" } = format(date, "%U")
    assert { :ok, "0" } = format(date, "%-W")
    assert { :ok, "0" } = format(date, "%-U")

    date = Date.from({2013,1,6})
    assert { :ok, "00" } = format(date, "%W")
    assert { :ok, "01" } = format(date, "%U")
    assert { :ok, "0" } = format(date, "%-W")
    assert { :ok, "1" } = format(date, "%-U")

    date = Date.from({2013,1,7})
    assert { :ok, "01" } = format(date, "%W")
    assert { :ok, "01" } = format(date, "%U")
    assert { :ok, "1" } = format(date, "%-W")
    assert { :ok, "1" } = format(date, "%-U")
  end

  test :format_iso_week do
    date = Date.from({2007,11,19})
    assert { :ok, "2007W471" } = format(date, "%GW%V%u")
    assert { :ok, "2007-W47-1" } = format(date, "%G-W%V-%u")
  end

  test :format_zones do
    eet = Date.timezone(2.0, "EET")
    date = Date.from({2007,11,19}, eet)
    assert { :ok, "EET" } = format(date, "%Z")
    assert { :ok, "+0200" } = format(date, "%z")
    assert { :ok, "+02:00" } = format(date, "%:z")
    assert { :ok, "+02:00:00" } = format(date, "%::z")

    pst = Date.timezone(-8.0, "PST")
    date = Date.from({2007,11,19}, pst)
    assert { :ok, "PST" } = format(date, "%Z")
    assert { :ok, "-0800" } = format(date, "%z")
    assert { :ok, "-08:00" } = format(date, "%:z")
    assert { :ok, "-08:00:00" } = format(date, "%::z")
  end

  test :format_dates do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,8})

    assert { :ok, "2013-8-18" } = format(date, "%Y-%-m-%d")
    assert { :ok, "3/08/08" } = format(old_date, "%-Y/%m/%d")
    assert { :ok, "3/08/08" } = format(old_date, "%-Y/%0m/%0d")
    assert { :ok, "03 8 8" } = format(old_date, "%y%_m%_d")

    assert { :ok, "8 2013 18" } = format(date, "%-m %Y %e")
    assert { :ok, " 8/08/ 3" } = format(old_date, "%_e/%m/%_y")
    assert { :ok, "8" } = format(date, "%-m")
    assert { :ok, "18" } = format(date, "%-d")
  end

  test :format_times do
    date = Date.from({{2013,8,18}, {16,28,27}})
    date2 = Date.from({{2013,8,18}, {12,3,4}})
    date_midnight = Date.from({{2013,8,18}, {0,3,4}})

    assert { :ok, "16" } = format(date, "%H")
    assert { :ok, "16" } = format(date, "%k")
    assert { :ok, "4" } = format(date, "%-I")
    assert { :ok, "4" } = format(date, "%-l")
    assert { :ok, "04" } = format(date, "%I")
    assert { :ok, " 4" } = format(date, "%l")

    assert { :ok, "12: 3: 4" } = format(date2, "%H:%_M:%_S")
    assert { :ok, "12:03:04" } = format(date2, "%k:%M:%S")
    assert { :ok, "12:03:04 PM" } = format(date2, "%I:%0M:%0S %p")
    assert { :ok, "pm 12:3:4" } = format(date2, "%P %l:%-M:%-S")
    assert { :ok, "am 12" } = format(date_midnight, "%P %I")
    assert { :ok, "am 12" } = format(date_midnight, "%P %l")
    assert { :ok, "AM 0" } = format(date_midnight, "%p %-H")
    assert { :ok, "AM 0" } = format(date_midnight, "%p %-k")
    assert { :ok, "AM 00" } = format(date_midnight, "%p %H")
    assert { :ok, "AM  0" } = format(date_midnight, "%p %k")

    fmt = "#{Date.to_sec(date)}"
    assert { :ok, ^fmt } = format(date, "%s")

    date = Date.from({{2001,9,9},{1,46,40}})
    assert { :ok, "1000000000" } = format(date, "%s")
  end

  test :combined_directives do
    date = Date.from({{2013,8,18}, {16,28,27}})
    assert { :ok, "08/18/13" } = format(date, "%D")
    assert { :ok, "2013-08-18" } = format(date, "%F")
    assert { :ok, "16:28" } = format(date, "%R")
    assert { :ok, "04:28:27 PM" } = format(date, "%r")
    assert { :ok, "16:28:27" } = format(date, "%T")

    date = Date.from({{2013,8,1}, {16,28,27}})
    assert { :ok, " 1-Aug-2013" } = format(date, "%v")
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
