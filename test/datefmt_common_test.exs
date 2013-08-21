defmodule DateFmtTest do
  use ExUnit.Case, async: true

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
end
