Dim As String   t_param, param(Any) ' temp.-string | string array
Dim As Long     num = 1 ' start index for Command()
ReDim param(0)  ' initialize dynamic array (start size = 1 element)

t_param = Command(num)  ' get first parameter
If t_param = "" Then    ' if first = 'empty' set ERROR
    param(num-1) = "no parameter(s) given!"
Else                    ' no ERROR (aka: OK), store current, get mext
    While t_param <> "" ' run until temp.-string = 'empty'
        ReDim Preserve param(num-1) ' increase array size (keep data)
        param(num-1) = t_param  ' assign temporary string to array
        num += 1        ' increase param number (to next)
        t_param = Command(num)  ' get next param (or 'empty')
    Wend
End If
' now we have all parameters in the string array: param()

' just in case, we need a certain number of mandatory param's:
If UBound(param) < 3 Then   ' assume: min.-parameters = 4
    ' give user a relevant message and, quit the prog. here
End If

' show it's content to user ... (even if only: ERROR-MSG)
For i As UInteger = 0 To UBound(param)
    ? "array param("; i; ") = "; param(i)
Next
If (num>1) then
	Vendor = valint("&h" + param(0))
	Product = valint("&h" + param(1))
End If
If (num>3) then
	sup_out = valint(param(2))
End If

