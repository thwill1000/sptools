' Copyright (c) 2020-2021 Thomas Hugo Williams
' License MIT <https://opensource.org/licenses/MIT>
' For Colour Maximite 2, MMBasic 5.07

Option Explicit On
Option Default None
Option Base InStr(Mm.CmdLine$, "--base=1") > 0

#Include "../system.inc"
#Include "../array.inc"
#Include "../list.inc"
#Include "../string.inc"
#Include "../file.inc"
#Include "../vt100.inc"
#Include "../../sptest/unittest.inc"

Const BASE% = Mm.Info(Option Base)
Const RSRC$ = file.get_canonical$(file.PROG_DIR$ + "/resources/tst_file")

add_test("test_get_parent")
add_test("test_get_name")
add_test("test_get_canonical")
add_test("test_exists")
add_test("test_is_absolute")
add_test("test_is_directory")
add_test("test_fnmatch")
add_test("test_find_all")
add_test("test_find_files")
add_test("test_find_dirs")
add_test("test_find_all_matching")
add_test("test_find_files_matching")
add_test("test_find_dirs_matching")
add_test("test_count_files")
add_test("test_get_extension")
add_test("test_get_files")
add_test("test_trim_extension")

If InStr(Mm.CmdLine$, "--base") Then run_tests() Else run_tests("--base=1")

End

Sub setup_test()
End Sub

Sub teardown_test()
End Sub

Sub test_get_parent()
  assert_string_equals("", file.get_parent$("foo.bas"))
  assert_string_equals("test", file.get_parent$("test/foo.bas"))
  assert_string_equals("test", file.get_parent$("test\foo.bas"))
  assert_string_equals("A:/test", file.get_parent$("A:/test/foo.bas"))
  assert_string_equals("A:\test", file.get_parent$("A:\test\foo.bas"))
  assert_string_equals("..", file.get_parent$("../foo.bas"))
  assert_string_equals("..", file.get_parent$("..\foo.bas"))
End Sub

Sub test_get_name()
  assert_string_equals("foo.bas", file.get_name$("foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("test/foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("test\foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("A:/test/foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("A:\test\foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("../foo.bas"))
  assert_string_equals("foo.bas", file.get_name$("..\foo.bas"))
End Sub

Sub test_get_canonical()
  Local root$ = Mm.Info(Directory)
  assert_string_equals(root$ + "foo.bas", file.get_canonical$("foo.bas"))
  assert_string_equals(root$ + "dir/foo.bas", file.get_canonical$("dir/foo.bas"))
  assert_string_equals(root$ + "dir/foo.bas", file.get_canonical$("dir\foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("A:/dir/foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("A:\dir\foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("a:/dir/foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("a:\dir\foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("/dir/foo.bas"))
  assert_string_equals("A:/dir/foo.bas", file.get_canonical$("\dir\foo.bas"))
  assert_string_equals(root$ + "foo.bas", file.get_canonical$("dir/../foo.bas"))
  assert_string_equals(root$ + "foo.bas", file.get_canonical$("dir\..\foo.bas"))
  assert_string_equals(root$ + "dir/foo.bas", file.get_canonical$("dir/./foo.bas"))
  assert_string_equals(root$ + "dir/foo.bas", file.get_canonical$("dir\.\foo.bas"))
  assert_string_equals("A:", file.get_canonical$("A:"))
  assert_string_equals("A:", file.get_canonical$("A:/"))
  assert_string_equals("A:", file.get_canonical$("A:\"))
  assert_string_equals("A:", file.get_canonical$("/"))
  assert_string_equals("A:", file.get_canonical$("\"))
End Sub

Sub test_exists()
  Local f$ = Mm.Info$(Current)

  assert_true(file.exists%(f$))
  assert_true(file.exists%(file.get_parent$(f$) + "/foo/../" + file.get_name$(f$)))
  assert_true(file.exists%(file.PROG_DIR$))
  assert_true(file.exists%("A:"))
  assert_true(file.exists%("A:/"))
  assert_true(file.exists%("A:\"))
  assert_true(file.exists%("/"))
  assert_true(file.exists%("\"))

  assert_false(file.exists%(file.get_parent$(f$) + "/foo/" + file.get_name$(f$)))
End Sub

Sub test_is_absolute()
  assert_false(file.is_absolute%("foo.bas"))
  assert_false(file.is_absolute%("dir/foo.bas"))
  assert_false(file.is_absolute%("dir\foo.bas"))
  assert_true(file.is_absolute%("A:/dir/foo.bas"))
  assert_true(file.is_absolute%("A:\dir\foo.bas"))
  assert_true(file.is_absolute%("a:/dir/foo.bas"))
  assert_true(file.is_absolute%("a:\dir\foo.bas"))
  assert_true(file.is_absolute%("/dir/foo.bas"))
  assert_true(file.is_absolute%("\dir\foo.bas"))
  assert_false(file.is_absolute%("dir/../foo.bas"))
  assert_false(file.is_absolute%("dir\..\foo.bas"))
  assert_false(file.is_absolute%("dir/./foo.bas"))
  assert_false(file.is_absolute%("dir\.\foo.bas"))

  assert_true(file.is_absolute%("A:"))
  assert_true(file.is_absolute%("A:/"))
  assert_true(file.is_absolute%("A:\"))
  assert_true(file.is_absolute%("/"))
  assert_true(file.is_absolute%("\"))
End Sub

Sub test_is_directory()
  assert_true(file.is_directory%(file.PROG_DIR$))
  assert_true(file.is_directory%("A:"))
  assert_true(file.is_directory%("A:/"))
  assert_true(file.is_directory%("A:\"))
  assert_true(file.is_directory%("/"))
  assert_true(file.is_directory%("\"))

  assert_false(file.is_directory%(Mm.Info$(Current)))
End Sub

Sub test_fnmatch()
  ' Matches.
  assert_true(file.fnmatch%("foo",   "foo"))
  assert_true(file.fnmatch%("foo",   "FOO"))
  assert_true(file.fnmatch%("FOO",   "foo"))
  assert_true(file.fnmatch%("fo?",   "foo"))
  assert_true(file.fnmatch%("f??",   "foo"))
  assert_true(file.fnmatch%("???",   "foo"))
  assert_true(file.fnmatch%("?oo",   "foo"))
  assert_true(file.fnmatch%("?o?",   "foo"))
  assert_true(file.fnmatch%("*",     "foo.txt"))
  assert_true(file.fnmatch%("*.txt", "foo.txt"))
  assert_true(file.fnmatch%("f*.*",  "foo.txt"))
  assert_true(file.fnmatch%("f?o.*", "foo.txt"))

  ' Non-matches.
  assert_false(file.fnmatch%("foo",   "bar"))
  assert_false(file.fnmatch%("foo?",  "foo"))
  assert_false(file.fnmatch%("?foo",  "foo"))
  assert_false(file.fnmatch%("?",     "foo"))
  assert_false(file.fnmatch%("??",    "foo"))
  assert_false(file.fnmatch%("????",  "foo"))
  assert_false(file.fnmatch%("*.txt", "foo.bin"))
End Sub

Sub test_find_all()
  assert_string_equals(RSRC$,                                 file.find$(RSRC$, "*", "all"))
  assert_string_equals(RSRC$ + "/snafu-dir",                  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/one.foo",          file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir",           file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/five.foo",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/four.bar",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/three.bar",        file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/two.foo",          file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir",                 file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/one.foo",         file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir",          file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/five.foo", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/four.bar", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/three.bar",       file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/two.foo",         file.find$())
  assert_string_equals(RSRC$ + "/zzz.txt",                    file.find$())
  assert_string_equals("",                                    file.find$())
End Sub

Sub test_find_files()
  assert_string_equals(RSRC$ + "/snafu-dir/one.foo",          file.find$(RSRC$, "*", "file"))
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/five.foo",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/four.bar",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/three.bar",        file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/two.foo",          file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/one.foo",         file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/five.foo", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/four.bar", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/three.bar",       file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/two.foo",         file.find$())
  assert_string_equals(RSRC$ + "/zzz.txt",                    file.find$())
  assert_string_equals("",                                    file.find$())
End Sub

Sub test_find_dirs()
  assert_string_equals(RSRC$,                        file.find$(RSRC$, "*", "dir"))
  assert_string_equals(RSRC$ + "/snafu-dir",         file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir",  file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir",        file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir", file.find$())
  assert_string_equals("",                           file.find$())
End Sub

Sub test_find_all_matching()
  assert_string_equals(RSRC$,                                 file.find$(RSRC$, "*f*", "all"))
  assert_string_equals(RSRC$ + "/snafu-dir",                  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/one.foo",          file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/five.foo",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/four.bar",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/two.foo",          file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/one.foo",         file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/five.foo", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/four.bar", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/two.foo",         file.find$())
  assert_string_equals("",                                    file.find$())
End Sub

Sub test_find_files_matching()
  assert_string_equals(RSRC$ + "/snafu-dir/one.foo",          file.find$(RSRC$, "*.foo", "file"))
  assert_string_equals(RSRC$ + "/snafu-dir/subdir/five.foo",  file.find$())
  assert_string_equals(RSRC$ + "/snafu-dir/two.foo",          file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/one.foo",         file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/subdir/five.foo", file.find$())
  assert_string_equals(RSRC$ + "/wombat-dir/two.foo",         file.find$())
  assert_string_equals("",                                    file.find$())
End Sub

Sub test_find_dirs_matching()
  assert_string_equals(RSRC$ + "/snafu-dir/subdir",  file.find$(RSRC$, "*ub*", "dir"))
  assert_string_equals(RSRC$ + "/wombat-dir/subdir", file.find$())
  assert_string_equals("",                           file.find$())
End Sub

Sub test_count_files()
  assert_int_equals(3, file.count_files%(RSRC$, "*", "all"))
  assert_int_equals(1, file.count_files%(RSRC$, "*fu*", "all"))
  assert_int_equals(4, file.count_files%(RSRC$ + "/snafu-dir", "*", "all"))
  assert_int_equals(2, file.count_files%(RSRC$ + "/snafu-dir", "*.foo", "all"))
  assert_int_equals(1, file.count_files%(RSRC$ + "/snafu-dir", "*.bar", "all"))
  assert_int_equals(2, file.count_files%(RSRC$ + "/snafu-dir", "*r", "all"))

  assert_int_equals(1, file.count_files%(RSRC$, "*", "file"))
  assert_int_equals(0, file.count_files%(RSRC$, "*fu*", "file"))
  assert_int_equals(3, file.count_files%(RSRC$ + "/snafu-dir", "*", "file"))
  assert_int_equals(2, file.count_files%(RSRC$ + "/snafu-dir", "*.foo", "file"))
  assert_int_equals(1, file.count_files%(RSRC$ + "/snafu-dir", "*.bar", "file"))
  assert_int_equals(1, file.count_files%(RSRC$ + "/snafu-dir", "*r", "file"))

  assert_int_equals(2, file.count_files%(RSRC$, "*", "dir"))
  assert_int_equals(1, file.count_files%(RSRC$, "*fu*", "dir"))
  assert_int_equals(1, file.count_files%(RSRC$ + "/snafu-dir", "*", "dir"))
  assert_int_equals(0, file.count_files%(RSRC$ + "/snafu-dir", "*.foo", "dir"))
  assert_int_equals(0, file.count_files%(RSRC$ + "/snafu-dir", "*.bar", "dir"))
  assert_int_equals(1, file.count_files%(RSRC$ + "/snafu-dir", "*r", "dir"))
End Sub

Sub test_get_extension()
  assert_string_equals(".dat", file.get_extension$("foo.dat"))
  assert_string_equals("", file.get_extension$(""))
  assert_string_equals("", file.get_extension$("foo"))
  assert_string_equals(".dat", file.get_extension$(".dat"))
  assert_string_equals(".dat", file.get_extension$("f.dat"))
  assert_string_equals(".dat", file.get_extension$("foo.bar.dat"))
  assert_string_equals(".dat", file.get_extension$("bugaloo/foo.dat"))
  assert_string_equals("", file.get_extension$("wom.bat/foo"))
  assert_string_equals("", file.get_extension$("wom.bat\foo"))
  assert_string_equals(".dat", file.get_extension$("wom.bat/foo.dat"))
  assert_string_equals(".dat", file.get_extension$("wom.bat\foo.dat"))
  assert_string_equals("", file.get_extension$("A:/foo"))
  assert_string_equals("", file.get_extension$("A:\foo"))
  assert_string_equals(".dat", file.get_extension$("A:/foo.dat"))
  assert_string_equals(".dat", file.get_extension$("A:\foo.dat"))
  assert_string_equals("", file.get_extension$("/foo"))
  assert_string_equals("", file.get_extension$("\foo"))
  assert_string_equals(".dat", file.get_extension$("/foo.dat"))
  assert_string_equals(".dat", file.get_extension$("\foo.dat"))
  assert_string_equals(".longer", file.get_extension$("foo.longer"))
  assert_string_equals(".", file.get_extension$("foo."))
End Sub

Sub test_get_files()
  Local actual$(array.new%(10)) Length 128
  Local expected$(array.new%(10)) Length 128

  ' Type = ALL

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*r*", "all", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "subdir"
  expected$(BASE% + 1) = "three.bar"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*R*", "ALL", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "subdir"
  expected$(BASE% + 1) = "three.bar"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*xyz*", "ALL", actual$())
  array.fill(expected$(), "")
  assert_string_array_equals(expected$(), actual$())

  ' Type = DIR

  array.fill(actual$(), "")
  file.get_files(RSRC$, "*", "dir", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "snafu-dir"
  expected$(BASE% + 1) = "wombat-dir"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$, "*fu*", "dir", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "snafu-dir"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$, "*.foo", "dir", actual$())
  array.fill(expected$(), "")
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*r*", "dir", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "subdir"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*R*", "DIR", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "subdir"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "subdir", "DIR", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "subdir"
  assert_string_array_equals(expected$(), actual$())

  ' Type = FILE

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*r*", "file", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "three.bar"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "*R*", "FILE", actual$())
  array.fill(expected$(), "")
  expected$(BASE% + 0) = "three.bar"
  assert_string_array_equals(expected$(), actual$())

  array.fill(actual$(), "")
  file.get_files(RSRC$ + "/snafu-dir", "subdir", "FILE", actual$())
  array.fill(expected$(), "")
  assert_string_array_equals(expected$(), actual$())
End Sub

Sub test_trim_extension()
  assert_string_equals("foo",         file.trim_extension$("foo.dat"))
  assert_string_equals("",            file.trim_extension$(""))
  assert_string_equals("foo",         file.trim_extension$("foo"))
  assert_string_equals("",            file.trim_extension$(".dat"))
  assert_string_equals("f",           file.trim_extension$("f.dat"))
  assert_string_equals("foo.bar",     file.trim_extension$("foo.bar.dat"))
  assert_string_equals("bugaloo/foo", file.trim_extension$("bugaloo/foo.dat"))
  assert_string_equals("wom.bat/foo", file.trim_extension$("wom.bat/foo"))
  assert_string_equals("wom.bat\foo", file.trim_extension$("wom.bat\foo"))
  assert_string_equals("wom.bat/foo", file.trim_extension$("wom.bat/foo.dat"))
  assert_string_equals("wom.bat\foo", file.trim_extension$("wom.bat\foo.dat"))
  assert_string_equals("A:/foo",      file.trim_extension$("A:/foo"))
  assert_string_equals("A:\foo",      file.trim_extension$("A:\foo"))
  assert_string_equals("A:/foo",      file.trim_extension$("A:/foo.dat"))
  assert_string_equals("A:\foo",      file.trim_extension$("A:\foo.dat"))
  assert_string_equals("/foo",        file.trim_extension$("/foo"))
  assert_string_equals("\foo",        file.trim_extension$("\foo"))
  assert_string_equals("/foo",        file.trim_extension$("/foo.dat"))
  assert_string_equals("\foo",        file.trim_extension$("\foo.dat"))
  assert_string_equals("foo",         file.trim_extension$("foo.longer"))
  assert_string_equals("foo",         file.trim_extension$("foo."))
End Sub
