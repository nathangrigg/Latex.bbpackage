property typeset_script_name : "00)Typeset Latex.scpt"

-- get file information
tell application "BBEdit"
	try
		set _doc to front document
		set _filename to file of _doc
		set _delims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "/"
		set _path to (text items 1 thru -2 of POSIX path of _filename) as string
		set AppleScript's text item delimiters to _delims
	on error
		display dialog "I cannot find an open BBEdit document" buttons {"Quit"} default button "Quit"
		return
	end try
end tell


-- get revision information from git
try
	set _info to do shell script "cd " & quoted form of _path & "; " & "git log -1 --date=short --format=format:'\\newcommand{\\RevisionInfo}{Revision %h on %ad}'"
on error
	display dialog "Cannot find git revision information. Check that the file is inside a repository." buttons {"Quit"} default button "Quit"
	return
end try

set _me to POSIX path of (path to me)
set AppleScript's text item delimiters to "/"
set _path to (text items 1 thru -2 of (POSIX path of (path to me)) as string)
set AppleScript's text item delimiters to _delims

try
	set typeset_script to load script POSIX file ("/" & _path & "/" & typeset_script_name as string)
on error
	display dialog "Cannot load script \"" & typeset_script_name & "\", which is required." buttons {"Quit"} default button "Quit"
	return
end try

set typeset_script's gitinfo to _info

typeset_script's typeset()
