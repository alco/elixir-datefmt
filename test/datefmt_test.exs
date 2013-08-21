defmodule DateFmtTest do
  use ExUnit.Case

  test :format_year do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,18})

    assert { :ok, "a2013b" } = DateFmt.format(date, "a{YYYY}b")

    assert { :ok, "a3b" } = DateFmt.format(old_date, "a{YYYY}b")
    assert { :ok, "a0003b" } = DateFmt.format(old_date, "a{0YYYY}b")
    assert { :ok, "a   3b" } = DateFmt.format(old_date, "a{_YYYY}b")
    assert { :ok, "a3b" }  = DateFmt.format(old_date, "a{YY}b")
    assert { :ok, "a03b" } = DateFmt.format(old_date, "a{0YY}b")
    assert { :ok, "a 3b" } = DateFmt.format(old_date, "a{_YY}b")
  end

  test :format_ordinal_day do
    date = Date.from({3,2,1})

    assert { :ok, "32" } = DateFmt.format(date, "{Dord}")
    assert { :ok, "032" } = DateFmt.format(date, "{0Dord}")
    assert { :ok, " 32" } = DateFmt.format(date, "{_Dord}")

    date = Date.from({3,12,31})
    assert { :ok, "365" } = DateFmt.format(date, "{Dord}")

    date = Date.from({3,1,1})
    assert { :ok, "001" } = DateFmt.format(date, "{0Dord}")

    date = Date.from({2007,11,19})
    assert { :ok, "2007323" } = DateFmt.format(date, "{YYYY}{Dord}")
    assert { :ok, "2007-323" } = DateFmt.format(date, "{YYYY}-{Dord}")

    date = Date.from({2007,11,18})
    assert { :ok, "0" } = DateFmt.format(date, "{WDsun}")
    assert { :ok, "7" } = DateFmt.format(date, "{WDmon}")
  end

  test :format_names do
    date = Date.from({2013,1,1})
    assert { :ok, "Tue" } = DateFmt.format(date, "{WDshort}")
    assert { :ok, "Tuesday" } = DateFmt.format(date, "{WDfull}")

    assert { :ok, "Jan" } = DateFmt.format(date, "{Mshort}")
    assert { :ok, "January" } = DateFmt.format(date, "{Mfull}")
  end

  test :format_ordinal_week do
    date = Date.from({2013,1,1})
    assert { :ok, "0" } = DateFmt.format(date, "{Wmon}")
    assert { :ok, "0" } = DateFmt.format(date, "{Wsun}")

    date = Date.from({2013,1,6})
    assert { :ok, "0" } = DateFmt.format(date, "{Wmon}")
    assert { :ok, "1" } = DateFmt.format(date, "{Wsun}")

    date = Date.from({2013,1,7})
    assert { :ok, "1" } = DateFmt.format(date, "{Wmon}")
    assert { :ok, "1" } = DateFmt.format(date, "{Wsun}")

    date = Date.from({2012,1,1})
    assert { :ok, "0" } = DateFmt.format(date, "{Wmon}")
    assert { :ok, "1" } = DateFmt.format(date, "{Wsun}")

    date = Date.from({2012,1,2})
    assert { :ok, "1" } = DateFmt.format(date, "{Wmon}")
    assert { :ok, "1" } = DateFmt.format(date, "{Wsun}")
  end

  test :format_iso_week do
    date = Date.from({2007,11,19})
    assert { :ok, "2007W471" } = DateFmt.format(date, "{WYYYY}W{Wiso}{WDmon}")
    assert { :ok, "2007-W47-1" } = DateFmt.format(date, "{WYYYY}-W{Wiso}-{WDmon}")
  end

  test :format_zones do
    assert nil
  end

  test :format_dates do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,8})

    assert { :ok, "2013-8-18" } = DateFmt.format(date, "{YYYY}-{M}-{D}")
    assert { :ok, "3/08/08" } = DateFmt.format(old_date, "{YYYY}/{0M}/{0D}")
    assert { :ok, "03 8 8" } = DateFmt.format(old_date, "{0YY}{_M}{_D}")

    assert { :ok, "8 2013 18" } = DateFmt.format(date, "{M} {YYYY} {D}")
    assert { :ok, " 8/08/ 3" } = DateFmt.format(old_date, "{_D}/{0M}/{_YY}")
    assert { :ok, "8" } = DateFmt.format(date, "{M}")
    assert { :ok, "18" } = DateFmt.format(date, "{D}")
  end

  test :format_times do
    date = Date.from({{2013,8,18}, {16,28,27}}, :utc)
    date2 = Date.from({{2013,8,18}, {12,3,4}}, :utc)
    date_midnight = Date.from({{2013,8,18}, {0,3,4}}, :utc)

    assert { :ok, "16" } = DateFmt.format(date, "{h24}")
    assert { :ok, "4" } = DateFmt.format(date, "{h12}")
    assert { :ok, "04" } = DateFmt.format(date, "{0h12}")
    assert { :ok, " 4" } = DateFmt.format(date, "{_h12}")

    assert { :ok, "12: 3: 4" } = DateFmt.format(date2, "{h24}:{_m}:{_s}")
    assert { :ok, "12:03:04" } = DateFmt.format(date2, "{h12}:{0m}:{0s}")
    assert { :ok, "12:03:04 PM" } = DateFmt.format(date2, "{h12}:{0m}:{0s} {AM}")
    assert { :ok, "pm 12:3:4" } = DateFmt.format(date2, "{am} {h24}:{m}:{s}")
    assert { :ok, "am 12" } = DateFmt.format(date_midnight, "{am} {h12}")
    assert { :ok, "AM 0" } = DateFmt.format(date_midnight, "{AM} {h24}")
    assert { :ok, "AM 00" } = DateFmt.format(date_midnight, "{AM} {0h24}")
  end

  # References:
  # http://www.ruby-doc.org/core-2.0/Time.html#method-i-strftime
  # http://golang.org/pkg/time/#pkg-constants
  test :format_full do
    date = Date.from({{2007,11,9}, {8,37,48}})

    #assert { :ok, "083748-0600" } = DateFmt.format(date, "")
    #assert { :ok, "08:37:48-06:00" } = DateFmt.format(date, "")
    #assert { :ok, "20071119T083748-0600" } = DateFmt.format(date, "")
    #assert { :ok, "2007-11-19T08:37:48-06:00" } = DateFmt.format(date, "")
    #assert { :ok, "2007323T083748-0600" } = DateFmt.format(date, "")
    #assert { :ok, "2007-323T08:37:48-06:00" } = DateFmt.format(date, "")
    #assert { :ok, "2007W471T083748-0600" } = DateFmt.format(date, "")
    #assert { :ok, "2007-W47-1T08:37:48-06:00" } = DateFmt.format(date, "")

    # ISO
    assert { :ok, "20071109T0837" } = DateFmt.format(date, "{YYYY}{M}{0D}T{0h24}{m}")
    assert { :ok, "2007-11-09T08:37" } = DateFmt.format(date, "{YYYY}-{M}-{0D}T{0h24}:{m}")

    #assert { :ok, "2007323T0837Z" } = DateFmt.format(date, "")
    #assert { :ok, "2007-323T08:37Z" } = DateFmt.format(date, "")
    #assert { :ok, "2007W471T0837-0600" } = DateFmt.format(date, "")
    #assert { :ok, "2007-W47-1T08:37-06:00" } = DateFmt.format(date, "")


    assert { :ok, "Fri Nov  9 08:37:48 2007" } = DateFmt.format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    #assert { :ok, "Mon Nov 19 08:37:48 MST 2007" } = DateFmt.format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    #assert { :ok, "Mon Nov 19 08:37:48 -0700 2007" } = DateFmt.format(date, "{WDshort} {Mshort} {_D} {0h24}:{0m}:{0s} {YYYY}")
    assert { :ok, "09 Nov 07 08:37" } = DateFmt.format(date, "{0D} {Mshort} {0YY} {0h24}:{0m}")

    assert { :ok, "8:37AM" } = DateFmt.format(date, "{h12}:{0m}{AM}")
  end

  test :format_iso do
    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)

    assert { :ok, "2013-03-05T21:25:19Z" } = DateFmt.format(date, :iso)
    assert { :ok, "2013-03-05T23:25:19" } = DateFmt.format(date, :iso_local)
    assert { :ok, "2013-03-05T23:25:19+0200" } = DateFmt.format(date, :iso_full)

    pst = Date.timezone(-8, "PST")
    local = {{2013,3,5},{23,25,19}}
    assert { :ok, "2013-03-05T23:25:19-0800" } = DateFmt.format(Date.from(local, pst), :iso_full)
    assert { :ok, "2013-03-05T23:25:19+0000" } = DateFmt.format(Date.from(local, :utc), :iso_full)

    assert { :ok, "2013-03-05" } = DateFmt.format(date, :iso_date)
    assert { :ok, "21:25:19" } = DateFmt.format(date, :iso_time)

    assert { :ok, "2013-W10" } = DateFmt.format(date, :iso_week)
    assert { :ok, "2013-W10-2" } = DateFmt.format(date, :iso_week_day)
    assert { :ok, "2013-064" } = DateFmt.format(date, :iso_ordinal)
  end

  test :format_rfc1123 do
    date = Date.from({{2013,3,5},{23,25,19}})
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 GMT" } = DateFmt.format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0000" } = DateFmt.format(date, :rfc1123z)

    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 EET" } = DateFmt.format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0200" } = DateFmt.format(date, :rfc1123z)

    pst = Date.timezone(-8, "PST")
    date = Date.from({{2013,3,5},{23,25,19}}, pst)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 PST" } = DateFmt.format(date, :rfc1123)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 -0800" } = DateFmt.format(date, :rfc1123z)
  end

  test :validate do
    assert :ok = DateFmt.validate ""
    assert :ok = DateFmt.validate "abc"
    assert :ok = DateFmt.validate "Use {{ as oft{{en as you like{{"
    assert :ok = DateFmt.validate "Same go}}es for }}"
    assert :ok = DateFmt.validate "{{abc}}"

    assert {:error, "missing } (starting at 0)"} = DateFmt.validate "{"
    assert {:error, "missing } (starting at 4)"} = DateFmt.validate "abc { def"
    assert {:error, "extraneous } at 4"} = DateFmt.validate "abc } def"
  end
end

defmodule DateFmt.DefaultTest do
  use ExUnit.Case, async: true

  test :tokenize_bins do
    assert {:ok,[""]} = DateFmt.Default.tokenize ""
    assert {:ok,["abc"]} = DateFmt.Default.tokenize "abc"
    assert {:ok,["Use {{ as oft{{en as you like{{"]} = DateFmt.Default.tokenize "Use {{ as oft{{en as you like{{"
    assert {:ok,["Same go}}es for }}"]} = DateFmt.Default.tokenize "Same go}}es for }}"
    assert {:ok,["{{abc}}"]} = DateFmt.Default.tokenize "{{abc}}"
  end

  #test :do_validate_year do
    #assert {:ok,["", {:YYYY,nil}, ""]} = DateFmt.Default.tokenize "{YYYY}"
    #assert {:ok,["", {:YYYY,"0"}, ""]} = DateFmt.Default.tokenize "{0YYYY}"
    #assert {:ok,["", {:YYYY," "}, ""]} = DateFmt.Default.tokenize "{_YYYY}"
    #assert {:error, "bad flag at 1"} = DateFmt.Default.tokenize "{-YYYY}"
  #end
end
