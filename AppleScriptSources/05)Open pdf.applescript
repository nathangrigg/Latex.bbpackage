-- user configurable varaibles
set viewer to "Skim"

-- save text item delimiters
set _delims to AppleScript's text item delimiters

tell application "BBEdit"
	-- Get document info and save
	try
		set _file to (file of document 1)
		set _filename to POSIX path of _file
		set _tex_position to startLine of selection
	on error
		display dialog "I cannot get the filename of any document."
		return
	end try

end tell

try
	set _path to term(POSIX path of (path to me), "/Contents/")
on error
	display dialog "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." buttons {"Quit"} default button "Quit"
	return
end try

set _script to _path & "Resources/directives.py"
try
	set _root to do shell script quoted form of _script & " root " & quoted form of _filename
on error
	set _root to _filename
end try

set AppleScript's text item delimiters to "."
set _pdf to ((text items 1 thru -2 of _root) as string) & ".pdf" as string
set AppleScript's text item delimiters to _delims

--open in viewer

--if using skim, you can do forward search
if viewer is "Skim" then

	try
		do shell script "/Applications/Skim.app/Contents/SharedSupport/displayline -r -b " & _tex_position & " " & quoted form of _pdf & " " & quoted form of _filename
	on error
		tell application viewer
			activate
			open _pdf
		end tell
	end try
else

	tell application viewer
		activate
		open _pdf
	end tell
end if

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return characters 1 thru (_l + _n - 1) of str as string
end term

