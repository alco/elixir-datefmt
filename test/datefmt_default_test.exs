defmodule DateFmtTest.Default do
  use ExUnit.Case, async: true

  test :format_year do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,18})

    assert { :ok, "a2013b" } = format(date, "a{YYYY}b")

    assert { :ok, "a3b" } = format(old_date, "a{YYYY}b")
    assert { :ok, "a0003b" } = format(old_date, "a{0YYYY}b")
    assert { :ok, "a   3b" } = format(old_date, "a{_YYYY}b")
    assert { :ok, "a3b" }  = format(old_date, "a{YY}b")
    assert { :ok, "a03b" } = format(old_date, "a{0YY}b")
    assert { :ok, "a 3b" } = format(old_date, "a{_YY}b")
  end

  test :format_ordinal_day do
    date = Date.from({3,2,1})

    assert { :ok, "32" } = format(date, "{Dord}")
    assert { :ok, "032" } = format(date, "{0Dord}")
    assert { :ok, " 32" } = format(date, "{_Dord}")

    date = Date.from({3,12,31})
    assert { :ok, "365" } = format(date, "{Dord}")

    date = Date.from({3,1,1})
    assert { :ok, "001" } = format(date, "{0Dord}")

    date = Date.from({2007,11,19})
    assert { :ok, "2007323" } = format(date, "{YYYY}{Dord}")
    assert { :ok, "2007-323" } = format(date, "{YYYY}-{Dord}")

    date = Date.from({2007,11,18})
    assert { :ok, "0" } = format(date, "{WDsun}")
    assert { :ok, "7" } = format(date, "{WDmon}")
  end

  test :format_names do
    date = Date.from({2013,1,1})
    assert { :ok, "Tue" } = format(date, "{WDshort}")
    assert { :ok, "Tuesday" } = format(date, "{WDfull}")

    assert { :ok, "Jan" } = format(date, "{Mshort}")
    assert { :ok, "January" } = format(date, "{Mfull}")
  end

  test :format_ordinal_week do
    date = Date.from({2013,1,1})
    assert { :ok, "0" } = format(date, "{Wmon}")
    assert { :ok, "0" } = format(date, "{Wsun}")

    date = Date.from({2013,1,6})
    assert { :ok, "0" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")

    date = Date.from({2013,1,7})
    assert { :ok, "1" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")

    date = Date.from({2012,1,1})
    assert { :ok, "0" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")

    date = Date.from({2012,1,2})
    assert { :ok, "1" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")
  end

  test :format_iso_week do
    date = Date.from({2007,11,19})
    assert { :ok, "2007W471" } = format(date, "{WYYYY}W{Wiso}{WDmon}")
    assert { :ok, "2007-W47-1" } = format(date, "{WYYYY}-W{Wiso}-{WDmon}")
  end

  test :format_zones do
    assert nil
  end

  test :format_dates do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,8})

    assert { :ok, "2013-8-18" } = format(date, "{YYYY}-{M}-{D}")
    assert { :ok, "3/08/08" } = format(old_date, "{YYYY}/{0M}/{0D}")
    assert { :ok, "03 8 8" } = format(old_date, "{0YY}{_M}{_D}")

    assert { :ok, "8 2013 18" } = format(date, "{M} {YYYY} {D}")
    assert { :ok, " 8/08/ 3" } = format(old_date, "{_D}/{0M}/{_YY}")
    assert { :ok, "8" } = format(date, "{M}")
    assert { :ok, "18" } = format(date, "{D}")
  end

  test :format_times do
    date = Date.from({{2013,8,18}, {16,28,27}}, :utc)
    date2 = Date.from({{2013,8,18}, {12,3,4}}, :utc)
    date_midnight = Date.from({{2013,8,18}, {0,3,4}}, :utc)

    assert { :ok, "16" } = format(date, "{h24}")
    assert { :ok, "4" } = format(date, "{h12}")
    assert { :ok, "04" } = format(date, "{0h12}")
    assert { :ok, " 4" } = format(date, "{_h12}")

    assert { :ok, "12: 3: 4" } = format(date2, "{h24}:{_m}:{_s}")
    assert { :ok, "12:03:04" } = format(date2, "{h12}:{0m}:{0s}")
    assert { :ok, "12:03:04 PM" } = format(date2, "{h12}:{0m}:{0s} {AM}")
    assert { :ok, "pm 12:3:4" } = format(date2, "{am} {h24}:{m}:{s}")
    assert { :ok, "am 12" } = format(date_midnight, "{am} {h12}")
    assert { :ok, "AM 0" } = format(date_midnight, "{AM} {h24}")
    assert { :ok, "AM 00" } = format(date_midnight, "{AM} {0h24}")
  end

  # References:
  # http://www.ruby-doc.org/core-2.0/Time.html#method-i-strftime
  # http://golang.org/pkg/time/#pkg-constants
  test :format_full do
    date = Date.from({{2007,11,9}, {8,37,48}})

    #assert { :ok, "083748-0600" } = format(date, "")
    #assert { :ok, "08:37:48-06:00" } = format(date, "")
    #assert { :ok, "20071119T083748-0600" } = format(date, "")
    #assert { :ok, "2007-11-19T08:37:48-06:00" } = format(date, "")
    #assert { :ok, "2007323T083748-0600" } = format(date, "")
    #assert { :ok, "2007-323T08:37:48-06:00" } = format(date, "")
    #assert { :ok, "2007W471T083748-0600" } = format(date, "")
    #assert { :ok, "2007-W47-1T08:37:48-06:00" } = format(date, "")

    # ISO
    assert { :ok, "20071109T0837" } = format(date, "{YYYY}{M}{0D}T{0h24}{m}")
    assert { :ok, "2007-11-09T08:37" } = format(date, "{YYYY}-{M}-{0D}T{0h24}:{m}")

    #assert { :ok, "2007323T0837Z" } = format(date, "")
    #assert { :ok, "2007-323T08:37Z" } = format(date, "")
    #assert { :ok, "2007W471T0837-0600" } = format(date, "")
    #assert { :ok, "2007-W47-1T08:37-06:00" } = format(date, "")


    assert { :ok, "Fri Nov  9 08:37:48 2007" } = format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    #assert { :ok, "Mon Nov 19 08:37:48 MST 2007" } = format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    #assert { :ok, "Mon Nov 19 08:37:48 -0700 2007" } = format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    assert { :ok, "09 Nov 07 08:37" } = format(date, "{0D} {Mshort} {0YY} {0h24}:{0m}")

    assert { :ok, "8:37AM" } = format(date, "{h12}:{0m}{AM}")
  end

  test :format_iso do
    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)

    assert { :ok, "2013-03-05T21:25:19Z" } = format(date, :iso)
    assert { :ok, "2013-03-05T23:25:19" } = format(date, :iso_local)
    assert { :ok, "2013-03-05T23:25:19+0200" } = format(date, :iso_full)

    pst = Date.timezone(-8, "PST")
    local = {{2013,3,5},{23,25,19}}
    assert { :ok, "2013-03-05T23:25:19-0800" } = format(Date.from(local, pst), :iso_full)
    assert { :ok, "2013-03-05T23:25:19+0000" } = format(Date.from(local, :utc), :iso_full)

    assert { :ok, "2013-03-05" } = format(date, :iso_date)
    assert { :ok, "21:25:19" } = format(date, :iso_time)

    assert { :ok, "2013-W10" } = format(date, :iso_week)
    assert { :ok, "2013-W10-2" } = format(date, :iso_week_day)
    assert { :ok, "2013-064" } = format(date, :iso_ordinal)
  end

  test :format_rfc1123 do
    date = Date.from({{2013,3,5},{23,25,19}})
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 GMT" } = format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0000" } = format(date, :rfc1123z)

    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 EET" } = format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0200" } = format(date, :rfc1123z)

    pst = Date.timezone(-8, "PST")
    date = Date.from({{2013,3,5},{23,25,19}}, pst)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 PST" } = format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 -0800" } = format(date, :rfc1123z)
  end

  test :validate do
    assert :ok = validate ""
    assert :ok = validate "abc"
    assert :ok = validate "Use {{ as oft{{en as you like{{"
    assert :ok = validate "Same go}}es for }}"
    assert :ok = validate "{{abc}}"

    assert {:error, "missing } (starting at 0)"} = validate "{"
    assert {:error, "missing } (starting at 4)"} = validate "abc { def"
    assert {:error, "extraneous } at 4"} = validate "abc } def"
  end

  test :tokenize_bins do
    assert {:ok,[""]} = tokenize ""
    assert {:ok,["abc"]} = tokenize "abc"
    assert {:ok,["Use {{ as oft{{en as you like{{"]} = tokenize "Use {{ as oft{{en as you like{{"
    assert {:ok,["Same go}}es for }}"]} = tokenize "Same go}}es for }}"
    assert {:ok,["{{abc}}"]} = tokenize "{{abc}}"
  end

  defp format(date, fmt) do
    DateFmt.format(date, fmt)
  end

  defp validate(fmt) do
    DateFmt.validate(fmt)
  end

  defp tokenize(fmt) do
    DateFmt.Default.tokenize(fmt)
  end
end
