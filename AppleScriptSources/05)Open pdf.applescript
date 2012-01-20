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

tell application "Finder"
	set _script to (POSIX path of ((container of (container of (path to me))) as text)) & "Resources/directives.py"
	try
		set _root to do shell script quoted form of _script & " root " & quoted form of _filename
	on error
		set _root to _filename
	end try
end tell

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
