' Copyright (c) 2020-2021 Thomas Hugo Williams
' License MIT <https://opensource.org/licenses/MIT>
' For Colour Maximite 2, MMBasic 5.07

On Error Skip 1 : Dim sys.VERSION$ = ""
If sys.VERSION$ = "" Then Error "'system.inc' not included"
sys.provides("options")
If sys.err$ <> "" Then Error sys.err$

Dim opt.all
Dim opt.brief
Dim opt.no_location
Dim opt.infile$      ' input file/path
Dim opt.outfile$     ' output file/path, empty for output to console

Sub opt.init()
  opt.all = 0
  opt.brief = 0
  opt.no_location = 0
  opt.infile$ = ""
  opt.outfile$ = ""
End Sub

' Sets the value for an option.
'
' If name$ or value$ are invalid then sets sys.err$.
Sub opt.set(name$, value$)
  Select Case LCase$(name$)
    Case "all"         : opt.set_all(value$)
    Case "brief"       : opt.set_brief(value$)
    Case "infile"      : opt.set_infile(value$)
    Case "no-location" : opt.set_no_location(value$)
    Case "outfile"     : opt.set_outfile(value$)
    Case Else
      sys.err$ = "unknown option: " + name$
  End Select
End Sub

Sub opt.set_all(v$)
  Select Case LCase$(v$)
    Case "default", "off", "0", "" : opt.all = 0
    Case "on", "1"                 : opt.all = 1
    Case Else
      sys.err$ = "expects 'on|off' argument"
  End Select
End Sub

Sub opt.set_brief(v$)
  Select Case LCase$(v$)
    Case "default", "off", "0", "" : opt.brief = 0
    Case "on", "1"                 : opt.brief = 1
    Case Else
      sys.err$ = "expects 'on|off' argument"
  End Select
End Sub

Sub opt.set_infile(v$)
  opt.infile$ = v$
End Sub

Sub opt.set_no_location(v$)
  Select Case LCase$(v$)
    Case "default", "off", "0", "" : opt.no_location = 0
    Case "on", "1"                 : opt.no_location = 1
    Case Else
      sys.err$ = "expects 'on|off' argument"
  End Select
End Sub

Sub opt.set_outfile(v$)
  opt.outfile$ = v$
End Sub
