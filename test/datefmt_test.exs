defmodule DateFmtTest do
  use ExUnit.Case

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

  test :do_validate do
    assert {:ok,[bin: ""]} = DateFmt.do_validate ""
    assert {:ok,[bin: "abc"]} = DateFmt.do_validate "abc"
    assert {:ok,[bin: "Use {{ as oft{{en as you like{{"]} = DateFmt.do_validate "Use {{ as oft{{en as you like{{"
    assert {:ok,[bin: "Same go}}es for }}"]} = DateFmt.do_validate "Same go}}es for }}"
    assert {:ok,[bin: "{{abc}}"]} = DateFmt.do_validate "{{abc}}"
  end
end
