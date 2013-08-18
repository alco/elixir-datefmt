defmodule DateFmtTest do
  use ExUnit.Case

  test :format_year do
    date = Date.from({{2013,8,18}, {16,28,27}}, :utc)
    old_date = Date.from({{3,8,18}, {16,28,27}}, :utc)

    assert { :ok, "a2013b" } = DateFmt.format(date, "a{YYYY}b")

    assert { :ok, "a3b" } = DateFmt.format(old_date, "a{YYYY}b")
    assert { :ok, "a0003b" } = DateFmt.format(old_date, "a{0YYYY}b")
    assert { :ok, "a   3b" } = DateFmt.format(old_date, "a{_YYYY}b")
    assert { :ok, "a3b" } = DateFmt.format(old_date, "a{YY}b")
    assert { :ok, "a03b" } = DateFmt.format(old_date, "a{0YY}b")
    assert { :ok, "a 3b" } = DateFmt.format(old_date, "a{_YY}b")
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

  test :do_validate_bins do
    assert {:ok,[""]} = DateFmt.do_validate ""
    assert {:ok,["abc"]} = DateFmt.do_validate "abc"
    assert {:ok,["Use {{ as oft{{en as you like{{"]} = DateFmt.do_validate "Use {{ as oft{{en as you like{{"
    assert {:ok,["Same go}}es for }}"]} = DateFmt.do_validate "Same go}}es for }}"
    assert {:ok,["{{abc}}"]} = DateFmt.do_validate "{{abc}}"
  end

  test :do_validate_year do
    assert {:ok,["", {:YYYY,nil}, ""]} = DateFmt.do_validate "{YYYY}"
    assert {:ok,["", {:YYYY,"0"}, ""]} = DateFmt.do_validate "{0YYYY}"
    assert {:ok,["", {:YYYY," "}, ""]} = DateFmt.do_validate "{_YYYY}"
    assert {:error, "bad flag at 1"} = DateFmt.do_validate "{-YYYY}"
  end
end
