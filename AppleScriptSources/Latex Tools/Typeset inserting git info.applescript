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

try
	set _path to term(POSIX path of (path to me), "/Contents/")
on error
	display dialog "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." buttons {"Quit"} default button "Quit"
	return
end try

try
	set typeset_script to load script POSIX file (_path & "Scripts/" & typeset_script_name as string)
on error
	display dialog "Cannot load script \"" & typeset_script_name & "\", which is required." buttons {"Quit"} default button "Quit"
	return
end try

set typeset_script's gitinfo to _info

typeset_script's typeset()

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return text 1 thru (_l + _n - 1) of str
end term
