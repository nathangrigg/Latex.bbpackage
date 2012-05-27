-- by Nathan Grigg

set texbin to "/usr/texbin"

try
	set _result to display dialog "Which package would you like documentation for?" default answer ""
on error
	return
end try

set _package to text returned of _result
set _message to do shell script "PATH=$PATH:" & quoted form of texbin & " ; texdoc " & (quoted form of _package)
if _message is not "" then
	try
		display dialog _message with title "Error" buttons "OK" default button "OK" cancel button "OK"
	end try
end if
