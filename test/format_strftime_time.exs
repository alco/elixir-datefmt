defmodule DateFmtTest.FormatStrftime do
  use ExUnit.Case, async: true

  test :format_year do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,18})

    assert { :ok, "2013" } = format(date, "%Y")
    assert { :ok, "13" }   = format(date, "%y")
    assert { :ok, "20" }   = format(date, "%C")
    assert { :ok, "0" }    = format(old_date, "%-C")
    assert { :ok, "00" }   = format(old_date, "%C")
    assert { :ok, "00" }   = format(old_date, "%0C")
    assert { :ok, " 0" }   = format(old_date, "%_C")

    assert { :ok, "3" }    = format(old_date, "%-Y")
    assert { :ok, "0003" } = format(old_date, "%Y")
    assert { :ok, "0003" } = format(old_date, "%0Y")
    assert { :ok, "   3" } = format(old_date, "%_Y")
    assert { :ok, "3" }    = format(old_date, "%-y")
    assert { :ok, "03" }   = format(old_date, "%y")
    assert { :ok, "03" }   = format(old_date, "%0y")
    assert { :ok, " 3" }   = format(old_date, "%_y")
  end

  test :format_iso_year do
    date = Date.from({2007,11,19})
    assert { :ok, "2007" } = format(date, "%G")
    assert { :ok, "7" }    = format(date, "%-g")
    assert { :ok, "07" }   = format(date, "%g")
    assert { :ok, "07" }   = format(date, "%0g")
    assert { :ok, " 7" }   = format(date, "%_g")

    date = Date.from({2006,1,1})
    assert { :ok, "2005" } = format(date, "%G")
    assert { :ok, "5" }    = format(date, "%-g")
    assert { :ok, "05" }   = format(date, "%g")
    assert { :ok, "05" }   = format(date, "%0g")
    assert { :ok, " 5" }   = format(date, "%_g")
  end

  test :format_month do
    date = Date.from({3,3,8})
    assert { :ok, "3" }  = format(date, "%-m")
    assert { :ok, "03" } = format(date, "%m")
    assert { :ok, "03" } = format(date, "%0m")
    assert { :ok, " 3" } = format(date, "%_m")
  end

  test :format_month_name do
    date = Date.from({2013,11,18})
    old_date = Date.from({3,3,8})

    assert { :ok, "Nov" }      = format(date, "%b")
    assert { :ok, "Nov" }      = format(date, "%h")
    assert { :ok, "November" } = format(date, "%B")
    assert { :ok, "Mar" }      = format(old_date, "%b")
    assert { :ok, "March" }    = format(old_date, "%B")

    assert { :error, "at 0: invalid flag for directive %b" } = format(date, "%0b")
    assert { :error, "at 0: invalid flag for directive %h" } = format(date, "%_h")
    assert { :error, "at 0: invalid flag for directive %B" } = format(date, "%-B")
  end

  test :format_day do
    date = Date.from({2013,8,18})
    old_date = Date.from({3,8,8})

    assert { :ok, "18" } = format(date, "%d")
    assert { :ok, "18" } = format(date, "%e")
    assert { :ok, "8" }  = format(old_date, "%-d")
    assert { :ok, "08" } = format(old_date, "%d")
    assert { :ok, "08" } = format(old_date, "%0d")
    assert { :ok, "08" } = format(old_date, "%0e")
    assert { :ok, " 8" } = format(old_date, "%e")
    assert { :ok, " 8" } = format(old_date, "%_d")
  end

  test :format_ordinal_day do
    date = Date.from({3,2,1})

    assert { :ok, "32" }  = format(date, "%-j")
    assert { :ok, "032" } = format(date, "%j")
    assert { :ok, "032" } = format(date, "%0j")
    assert { :ok, " 32" } = format(date, "%_j")

    date = Date.from({3,12,31})
    assert { :ok, "365" } = format(date, "%j")

    date = Date.from({3,1,1})
    assert { :ok, "001" } = format(date, "%j")
  end

  test :format_weekday do
    date = Date.from({2007,11,18})
    assert { :ok, "0" } = format(date, "%w")
    assert { :ok, "7" } = format(date, "%u")
    assert { :ok, "0" } = format(date, "%0w")
    assert { :ok, "7" } = format(date, "%-u")
    assert { :ok, "0" } = format(date, "%_w")
  end

  test :format_weekday_name do
    assert { :ok, "Mon" } = format(Date.from({2012,12,31}), "%a")
    assert { :ok, "Tue" } = format(Date.from({2013,1,1}), "%a")
    assert { :ok, "Wed" } = format(Date.from({2013,1,2}), "%a")
    assert { :ok, "Thu" } = format(Date.from({2013,1,3}), "%a")
    assert { :ok, "Fri" } = format(Date.from({2013,1,4}), "%a")
    assert { :ok, "Sat" } = format(Date.from({2013,1,5}), "%a")
    assert { :ok, "Sun" } = format(Date.from({2013,1,6}), "%a")
    assert { :error, "at 0: invalid flag for directive %a" } = format(Date.from({2013,1,6}), "%0a")
    assert { :error, "at 0: invalid flag for directive %a" } = format(Date.from({2013,1,6}), "%-a")

    assert { :ok, "Monday" }    = format(Date.from({2012,12,31}), "%A")
    assert { :ok, "Tuesday" }   = format(Date.from({2013,1,1}), "%A")
    assert { :ok, "Wednesday" } = format(Date.from({2013,1,2}), "%A")
    assert { :ok, "Thursday" }  = format(Date.from({2013,1,3}), "%A")
    assert { :ok, "Friday" }    = format(Date.from({2013,1,4}), "%A")
    assert { :ok, "Saturday" }  = format(Date.from({2013,1,5}), "%A")
    assert { :ok, "Sunday" }    = format(Date.from({2013,1,6}), "%A")
    assert { :error, "at 0: invalid flag for directive %A" } = format(Date.from({2013,1,6}), "%_A")
    assert { :error, "at 0: invalid flag for directive %A" } = format(Date.from({2013,1,6}), "%0A")
  end

  test :format_iso_week do
    date = Date.from({2007,11,19})
    assert { :ok, "47" } = format(date, "%V")
    assert { :ok, "47" } = format(date, "%0V")
    assert { :ok, "47" } = format(date, "%-V")

    date = Date.from({2007,1,1})
    assert { :ok, "1" }  = format(date, "%-V")
    assert { :ok, "01" } = format(date, "%V")
    assert { :ok, "01" } = format(date, "%0V")
    assert { :ok, " 1" } = format(date, "%_V")
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
    assert { :ok, " 0" } = format(date, "%_W")
    assert { :ok, " 1" } = format(date, "%_U")

    date = Date.from({2013,1,7})
    assert { :ok, "01" } = format(date, "%W")
    assert { :ok, "01" } = format(date, "%U")
    assert { :ok, "1" } = format(date, "%-W")
    assert { :ok, "1" } = format(date, "%-U")
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

  test :format_time do
    date = Date.from({{2013,8,18}, {16,28,27}})
    date_midnight = Date.from({{2013,8,18}, {0,3,4}})

    assert { :ok, "0" }  = format(date_midnight, "%-H")
    assert { :ok, "00" } = format(date_midnight, "%H")
    assert { :ok, "00" } = format(date_midnight, "%0H")
    assert { :ok, " 0" } = format(date_midnight, "%_H")
    assert { :ok, " 0" } = format(date_midnight, "%k")

    assert { :ok, "4" }  = format(date, "%-I")
    assert { :ok, "04" } = format(date, "%I")
    assert { :ok, "04" } = format(date, "%0I")
    assert { :ok, " 4" } = format(date, "%_I")
    assert { :ok, " 4" } = format(date, "%l")

    assert { :ok, "16" } = format(date, "%H")
    assert { :ok, "16" } = format(date, "%k")
    assert { :ok, "4" }  = format(date, "%-I")
    assert { :ok, "4" }  = format(date, "%-l")
    assert { :ok, "04" } = format(date, "%I")
    assert { :ok, " 4" } = format(date, "%l")

    date = Date.from({{2013,8,18}, {12,3,4}})
    assert { :ok, "12: 3: 4" } = format(date, "%H:%_M:%_S")
    assert { :ok, "12:03:04" } = format(date, "%k:%M:%S")
    assert { :ok, "12:03:04 PM" } = format(date, "%I:%0M:%0S %p")
    assert { :ok, "pm 12:3:4" } = format(date, "%P %l:%-M:%-S")
    assert { :ok, "am 12" } = format(date_midnight, "%P %I")
    assert { :ok, "am 12" } = format(date_midnight, "%P %l")
    assert { :ok, "AM 0" } = format(date_midnight, "%p %-H")
    assert { :ok, "AM 0" } = format(date_midnight, "%p %-k")
    assert { :ok, "AM 00" } = format(date_midnight, "%p %H")
    assert { :ok, "AM  0" } = format(date_midnight, "%p %k")

    assert { :error, "at 0: invalid flag for directive %p" } = format(date_midnight, "%0p")
    assert { :error, "at 0: invalid flag for directive %P" } = format(date_midnight, "%_P")

    assert { :ok, "1376827384" }  = format(date, "%s")
    assert { :ok, "1376827384" }  = format(date, "%-s")
    assert { :ok, "1376827384" }  = format(date, "%_s")

    date = Date.from({{2001,9,9},{1,46,40}})
    assert { :ok, "1000000000" } = format(date, "%s")

    date = Date.epoch()
    assert { :ok, "0" }           = format(date, "%-s")
    assert { :ok, "0000000000" }  = format(date, "%s")
    assert { :ok, "0000000000" }  = format(date, "%0s")
    assert { :ok, "         0" }  = format(date, "%_s")
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

    assert { :error, "at 0: invalid flag for directive %Z" } = format(date, "%0Z")
    assert { :error, "at 0: invalid flag for directive %Z" } = format(date, "%_Z")
    assert { :error, "at 0: bad directive %:" } = format(date, "%0:z")
    assert { :error, "at 0: bad directive %:" } = format(date, "%_::z")
  end

  test :combined_directives do
    date = Date.from({{2013,8,18}, {16,28,27}})
    assert { :ok, "08/18/13" }    = format(date, "%D")
    assert { :ok, "2013-08-18" }  = format(date, "%F")
    assert { :ok, "16:28" }       = format(date, "%R")
    assert { :ok, "04:28:27 PM" } = format(date, "%r")
    assert { :ok, "16:28:27" }    = format(date, "%T")

    date = Date.from({{2013,8,1}, {16,28,27}})
    assert { :ok, " 1-Aug-2013" } = format(date, "%v")
  end

  test :unicode do
    date = Date.from({{2007,11,9}, {8,37,48}})
    assert { :ok, "Fri å∫ç∂ {%08…37…48%} ¿UTC?" } = format(date, "%a å∫ç∂ {%%%H…%M…%S%%} ¿%Z?")
  end

  test :tokens do
    date = Date.now()
    assert {:ok, "" } = format(date, "")
    assert {:ok, "abc" } = format(date, "abc")
    assert {:ok, "Use % as oft{{en as you like%" } = format(date, "Use %% as oft{{en as you like%%")
    assert {:ok, "%%abc%" } = format(date, "%%%%abc%%")
  end

  defp format(date, fmt) do
    DateFmt.format(date, fmt, :strftime)
  end
end

defmodule DateFmtTest.ValidateStrftime do
  test :validate do
    assert :ok = validate ""
    assert :ok = validate "abc"
    assert :ok = validate "Use {{ as oft%%%%en as you like{{"
    assert :ok = validate "%%Same go}}es for }}%%"

    assert {:error, "at 0: bad directive"} = validate "%"
    assert {:error, "at 0: bad directive %^"} = validate "%^"
    assert {:error, "at 2: bad directive"} = validate "%%%"
    assert {:error, "at 0: bad directive %X"} = validate "%0X"
  end

  defp validate(fmt) do
    DateFmt.validate(fmt, :strftime)
  end
end
