-- by Nathan Grigg

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
	set _result to do shell script quoted form of _script & " root program " & quoted form of _filename
	set _root to paragraph 1 of _result
	set _tex_program to paragraph 2 of _result
on error
	set _root to _filename
	set _tex_program to "pdflatex"
end try

if {"tex", "etex", "eplain", "latex", "dviluatex", "dvilualatex", "xmltex", "jadetex", "mtex", "utf8mex", "cslatex", "csplain", "aleph", "lamed"} contains _tex_program then
	set _extension to ".dvi"
else
	set _extension to ".pdf"
end if

set AppleScript's text item delimiters to "."
set _pdf to ((text items 1 thru -2 of _root) as string) & _extension as string
set AppleScript's text item delimiters to _delims

--open in viewer

--if using skim, you can do forward search
if viewer is "Skim" then
	try
		-- check that Skim exists and get its path
		tell application "Finder" to set skim_path to POSIX path of (application file id "SKim" as alias)
	on error
		do shell script "open -g -a Preview " & quoted form of _pdf
		return
	end try

	try
		do shell script quoted form of skim_path & "Contents/SharedSupport/displayline -r -b -g " & _tex_position & " " & quoted form of _pdf & " " & quoted form of _filename
	on error
		-- this monstrosity allows the rest of the script to work even if Skim is not installed.
		do shell script "/usr/bin/osascript -e 'tell application \"Skim\"' -e 'set _window to open \"" & _pdf & "\"' -e 'revert _window' -e 'end tell'"

	end try
else
	do shell script "open -g -a " & quoted form of viewer & " " & quoted form of _pdf
end if

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return text 1 thru (_l + _n - 1) of str
end term
