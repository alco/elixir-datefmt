defmodule DateFmtTest.Default do
  use ExUnit.Case, async: true

  test :format_year do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,18})

    assert { :ok, "2013" } = format(date, "{YYYY}")
    assert { :ok, "13" }   = format(date, "{YY}")
    assert { :ok, "20" }   = format(date, "{C}")
    assert { :ok, "0" }    = format(old_date, "{C}")
    assert { :ok, "00" }   = format(old_date, "{0C}")
    assert { :ok, " 0" }   = format(old_date, "{_C}")

    assert { :ok, "3" }    = format(old_date, "{YYYY}")
    assert { :ok, "0003" } = format(old_date, "{0YYYY}")
    assert { :ok, "   3" } = format(old_date, "{_YYYY}")
    assert { :ok, "3" }    = format(old_date, "{YY}")
    assert { :ok, "03" }   = format(old_date, "{0YY}")
    assert { :ok, " 3" }   = format(old_date, "{_YY}")
  end

  test :format_iso_year do
    assert { :ok, "2007" } = format(Date.from({2007,11,19}), "{WYYYY}")
    assert { :ok, "7" }    = format(Date.from({2007,11,19}), "{WYY}")
    assert { :ok, "07" }   = format(Date.from({2007,11,19}), "{0WYY}")
    assert { :ok, " 7" }   = format(Date.from({2007,11,19}), "{_WYY}")
    assert { :ok, "2005" } = format(Date.from({2006,1,1}), "{WYYYY}")
    assert { :ok, "5" }    = format(Date.from({2006,1,1}), "{WYY}")
    assert { :ok, "05" }   = format(Date.from({2006,1,1}), "{0WYY}")
    assert { :ok, " 5" }   = format(Date.from({2006,1,1}), "{_WYY}")
  end

  test :format_month do
    date = Date.from({3,3,8})
    assert { :ok, "3" }  = format(date, "{M}")
    assert { :ok, "03" } = format(date, "{0M}")
    assert { :ok, " 3" } = format(date, "{_M}")
  end

  test :format_month_name do
    date = Date.from({2013,11,18})
    old_date = Date.from({3,3,8})

    assert { :ok, "Nov" }      = format(date, "{Mshort}")
    assert { :ok, "November" } = format(date, "{Mfull}")
    assert { :ok, "Mar" }      = format(old_date, "{Mshort}")
    assert { :ok, "March" }    = format(old_date, "{Mfull}")

    assert { :error, "at 0: bad directive" } = format(date, "{0Mfull}")
    assert { :error, "at 1: bad directive" } = format(old_date, " {_Mshort}")
  end

  test :format_day do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,8})

    assert { :ok, "18" } = format(date, "{D}")
    assert { :ok, "18" } = format(date, "{0D}")
    assert { :ok, "18" } = format(date, "{_D}")
    assert { :ok, "8" }  = format(old_date, "{D}")
    assert { :ok, "08" } = format(old_date, "{0D}")
    assert { :ok, " 8" } = format(old_date, "{_D}")
  end

  test :format_ordinal_day do
    date = Date.from({3,2,1})

    assert { :ok, "32" }  = format(date, "{Dord}")
    assert { :ok, "032" } = format(date, "{0Dord}")
    assert { :ok, " 32" } = format(date, "{_Dord}")

    date = Date.from({3,12,31})
    assert { :ok, "365" } = format(date, "{Dord}")

    date = Date.from({3,1,1})
    assert { :ok, "001" } = format(date, "{0Dord}")
  end

  test :format_weekday do
    date = Date.from({2007,11,18})
    assert { :ok, "0" } = format(date, "{WDsun}")
    assert { :ok, "7" } = format(date, "{WDmon}")
    assert { :error, "at 0: bad directive" } = format(date, "{0WDsun}")
    assert { :error, "at 0: bad directive" } = format(date, "{0WDmon}")
    assert { :error, "at 0: bad directive" } = format(date, "{_WDsun}")
    assert { :error, "at 0: bad directive" } = format(date, "{_WDmon}")
  end

  test :format_weekday_name do
    assert { :ok, "Mon" } = format(Date.from({2012,12,31}), "{WDshort}")
    assert { :ok, "Tue" } = format(Date.from({2013,1,1}), "{WDshort}")
    assert { :ok, "Wed" } = format(Date.from({2013,1,2}), "{WDshort}")
    assert { :ok, "Thu" } = format(Date.from({2013,1,3}), "{WDshort}")
    assert { :ok, "Fri" } = format(Date.from({2013,1,4}), "{WDshort}")
    assert { :ok, "Sat" } = format(Date.from({2013,1,5}), "{WDshort}")
    assert { :ok, "Sun" } = format(Date.from({2013,1,6}), "{WDshort}")
    assert { :error, "at 0: bad directive" } = format(Date.from({2013,1,6}), "{0WDshort}")
    assert { :error, "at 0: bad directive" } = format(Date.from({2013,1,6}), "{_WDshort}")

    assert { :ok, "Monday" }    = format(Date.from({2012,12,31}), "{WDfull}")
    assert { :ok, "Tuesday" }   = format(Date.from({2013,1,1}), "{WDfull}")
    assert { :ok, "Wednesday" } = format(Date.from({2013,1,2}), "{WDfull}")
    assert { :ok, "Thursday" }  = format(Date.from({2013,1,3}), "{WDfull}")
    assert { :ok, "Friday" }    = format(Date.from({2013,1,4}), "{WDfull}")
    assert { :ok, "Saturday" }  = format(Date.from({2013,1,5}), "{WDfull}")
    assert { :ok, "Sunday" }    = format(Date.from({2013,1,6}), "{WDfull}")
    assert { :error, "at 0: bad directive" } = format(Date.from({2013,1,6}), "{0WDfull}")
    assert { :error, "at 0: bad directive" } = format(Date.from({2013,1,6}), "{_WDfull}")
  end

  test :format_iso_week do
    date = Date.from({2007,11,19})
    assert { :ok, "47" } = format(date, "{Wiso}")
    assert { :ok, "47" } = format(date, "{0Wiso}")
    assert { :ok, "47" } = format(date, "{_Wiso}")

    date = Date.from({2007,1,1})
    assert { :ok, "1" }  = format(date, "{Wiso}")
    assert { :ok, "01" } = format(date, "{0Wiso}")
    assert { :ok, " 1" } = format(date, "{_Wiso}")
  end

  test :format_ordinal_week do
    date = Date.from({2013,1,1})
    assert { :ok, "0" } = format(date, "{Wmon}")
    assert { :ok, "0" } = format(date, "{Wsun}")

    date = Date.from({2013,1,6})
    assert { :ok, "00" } = format(date, "{0Wmon}")
    assert { :ok, "01" } = format(date, "{0Wsun}")

    date = Date.from({2013,1,7})
    assert { :ok, " 1" } = format(date, "{_Wmon}")
    assert { :ok, " 1" } = format(date, "{_Wsun}")

    date = Date.from({2012,1,1})
    assert { :ok, "0" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")

    date = Date.from({2012,1,2})
    assert { :ok, "1" } = format(date, "{Wmon}")
    assert { :ok, "1" } = format(date, "{Wsun}")

    date = Date.from({2012,12,31})
    assert { :ok, "53" } = format(date, "{Wmon}")
    assert { :ok, "53" } = format(date, "{Wsun}")
  end

  test :format_dates do
    # FIXME: better tests
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

  test :format_time do
    date = Date.from({{2013,8,18}, {16,28,27}})
    date_midnight = Date.from({{2013,8,18}, {0,3,4}})

    assert { :ok, "0" }  = format(date_midnight, "{h24}")
    assert { :ok, "00" } = format(date_midnight, "{0h24}")
    assert { :ok, " 0" } = format(date_midnight, "{_h24}")

    assert { :ok, "4" }  = format(date, "{h12}")
    assert { :ok, "04" } = format(date, "{0h12}")
    assert { :ok, " 4" } = format(date, "{_h12}")

    date = Date.from({{2013,8,18}, {12,3,4}})
    assert { :ok, "12: 3: 4" }    = format(date, "{h24}:{_m}:{_s}")
    assert { :ok, "12:03:04" }    = format(date, "{h12}:{0m}:{0s}")
    assert { :ok, "12:03:04 PM" } = format(date, "{h12}:{0m}:{0s} {AM}")
    assert { :ok, "pm 12:3:4" }   = format(date, "{am} {h24}:{m}:{s}")
    assert { :ok, "am 12" }       = format(date_midnight, "{am} {h12}")
    assert { :ok, "AM 00" }       = format(date_midnight, "{AM} {0h24}")

    assert { :error, "at 0: bad directive" } = format(date_midnight, "{0am}")
    assert { :error, "at 0: bad directive" } = format(date_midnight, "{_AM}")

    assert { :ok, "1376827384" }  = format(date, "{s-epoch}")
    assert { :ok, "1376827384" }  = format(date, "{0s-epoch}")
    assert { :ok, "1376827384" }  = format(date, "{_s-epoch}")

    date = Date.epoch()
    assert { :ok, "0" }           = format(date, "{s-epoch}")
    assert { :ok, "0000000000" }  = format(date, "{0s-epoch}")
    assert { :ok, "         0" }  = format(date, "{_s-epoch}")
  end

  test :format_zones do
    eet = Date.timezone(2.0, "EET")
    date = Date.from({2007,11,19}, eet)
    assert { :ok, "EET" } = format(date, "{Zname}")
    assert { :ok, "+0200" } = format(date, "{Z}")
    assert { :ok, "+02:00" } = format(date, "{Z:}")
    assert { :ok, "+02:00:00" } = format(date, "{Z::}")

    pst = Date.timezone(-8.0, "PST")
    date = Date.from({2007,11,19}, pst)
    assert { :ok, "PST" } = format(date, "{Zname}")
    assert { :ok, "-0800" } = format(date, "{Z}")
    assert { :ok, "-08:00" } = format(date, "{Z:}")
    assert { :ok, "-08:00:00" } = format(date, "{Z::}")

    assert { :error, "at 0: bad directive" } = format(date, "{0Zname}")
    assert { :error, "at 0: bad directive" } = format(date, "{_Z}")
    assert { :error, "at 0: bad directive" } = format(date, "{0Z:}")
    assert { :error, "at 0: bad directive" } = format(date, "{_Z::}")
  end

  test :format_compound_iso do
    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)
    assert { :ok, "2013-03-05T23:25:19+0200" } = format(date, "{ISO}")
    assert { :ok, "2013-03-05T21:25:19Z" }     = format(date, "{ISOz}")

    pst = Date.timezone(-8, "PST")
    local = {{2013,3,5},{23,25,19}}
    assert { :ok, "2013-03-05T23:25:19-0800" } = format(Date.from(local, pst), "{ISO}")
    assert { :ok, "2013-03-05T23:25:19+0000" } = format(Date.from(local, :utc), "{ISO}")


    date = Date.from({{2007,11,19}, {1,37,48}}, eet)

    assert { :ok, "2007-11-18" } = format(date, "{ISOdate}")
    assert { :ok, "20071119" }   = format(date, "{0YYYY}{0M}{0D}")
    assert { :ok, "0007-01-02" } = format(Date.from({7,1,2}), "{ISOdate}")

    assert { :ok, "23:37:48" } = format(date, "{ISOtime}")
    assert { :ok, "01:37:48" } = format(date, "{0h24}:{0m}:{0s}")
    assert { :ok, "23:03:09" } = format(Date.from({{1,2,3},{23,3,9}}), "{ISOtime}")
    assert { :ok, "23:03:09" } = format(Date.from({{1,2,3},{23,3,9}}), "{0h24}:{0m}:{0s}")

    assert { :ok, "2007-W47" }   = format(date, "{ISOweek}")
    assert { :ok, "2007-W47-1" } = format(date, "{ISOweek}-{WDmon}")
    assert { :ok, "2007-W47-1" } = format(date, "{ISOweek-day}")
    assert { :ok, "2007W471" }   = format(date, "{0WYYYY}W{0Wiso}{WDmon}")

    assert { :ok, "2007-322" }   = format(date, "{ISOord}")
    assert { :ok, "2007-323" }   = format(date, "{0YYYY}-{0Dord}")
  end

  test :format_compound_rfc1123 do
    date = Date.from({{2013,3,5},{23,25,19}})
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 GMT" } = format(date, "{RFC1123}")
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0000" } = format(date, "{RFC1123z}")

    eet = Date.timezone(2, "EET")
    date = Date.from({{2013,3,5},{23,25,19}}, eet)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 EET" } = format(date, "{RFC1123}")
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 +0200" } = format(date, "{RFC1123z}")

    pst = Date.timezone(-8, "PST")
    date = Date.from({{2013,3,5},{23,25,19}}, pst)
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 PST" } = format(date, "{RFC1123}")
    assert { :ok, "Tue, 05 Mar 2013 23:25:19 -0800" } = format(date, "{RFC1123z}")
  end

  test :format_compound_rfc3339 do
    local = {{2013,3,5},{23,25,19}}
    date = Date.from(local)

    assert { :ok, "2013-03-05T23:25:19Z" } = format(date, "{RFC3339}")

    eet = Date.timezone(2.0, "EET")
    assert { :ok, "2013-03-05T23:25:19+02:00" } = format(Date.from(local, eet), "{RFC3339}")
    pst = Date.timezone(-8.0, "PST")
    assert { :ok, "2013-03-05T23:25:19-08:00" } = format(Date.from(local, pst), "{RFC3339}")
  end

  test :format_compound_common do
    local = {{2013,3,5},{23,25,19}}
    date = Date.from(local)

    pst = Date.timezone(-8.0, "PST")
    assert { :ok, "Tue Mar  5 23:25:19 2013" } = format(date, "{ANSIC}")
    assert { :ok, "Tue Mar  5 23:25:19 UTC 2013" } = format(date, "{UNIX}")
    assert { :ok, "Tue Mar  5 23:25:19 PST 2013" } = format(Date.from(local, pst), "{UNIX}")

    date = Date.from({{2013,3,5},{15,25,19}})
    assert { :ok, "3:25PM" } = DateFmt.format(date, "{kitchen}")
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

  test :validate do
    assert :ok = validate ""
    assert :ok = validate "abc"
    assert :ok = validate "Use {{ as oft{{en as you like{{"
    assert :ok = validate "Same go}}es for }}"
    assert :ok = validate "{{abc}}"
    assert :ok = validate "abc } def"

    assert {:error, "at 0: missing }"} = validate "{"
    assert {:error, "at 4: missing }"} = validate "abc { def"
    assert {:error, "at 4: extraneous { in directive"} = validate "abc { { def"
    assert {:error, "at 4: bad directive"} = validate "abc {} def"
  end

  test :tokens do
    date = Date.now()
    assert {:ok, "" } = format(date, "")
    assert {:ok, "abc" } = format(date, "abc")
    assert {:ok, "Use { as oft{en as you like{" } = format(date, "Use {{ as oft{{en as you like{{")
    assert {:ok, "Same go}}es for }}" } = format(date, "Same go}}es for }}")
    assert {:ok, "{{abc}}" } = format(date, "{{{{abc}}")
    assert {:ok, "abc } def" } = format(date, "abc } def")
  end

  defp format(date, fmt) do
    DateFmt.format(date, fmt)
  end

  defp validate(fmt) do
    DateFmt.validate(fmt)
  end
end
