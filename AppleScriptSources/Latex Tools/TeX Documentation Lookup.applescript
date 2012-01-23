set texbin to "/usr/texbin"

try
	set _result to display dialog "Which package would you like documentation for?" default answer ""
on error
	return
end try

set _package to text returned of _result
set _message to do shell script texbin & "texdoc " & (quoted form of _package)
if _message is not "" then
	display dialog _message with title "Error" buttons "OK"
end if
