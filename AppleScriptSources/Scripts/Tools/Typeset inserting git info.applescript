-- by Nathan Grigg
-- get file information
property git_path : "/usr/local/bin/"

on main()
	set typeset_lib_file to path_to_contents() & "Resources/typeset-lib.scpt"
	set typeset_lib to load script POSIX file typeset_lib_file

	-- get folder containing tex file
	tell application "BBEdit"
		try
			set _doc to front document
			set _filename to file of _doc
			set _delims to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "/"
			set _path to (text items 1 thru -2 of POSIX path of _filename) as string
			set AppleScript's text item delimiters to _delims
		on error
			error "I cannot find an open BBEdit document" number 5033
		end try
	end tell

	-- get revision information from git
	try
		set _info to do shell script "PATH=$PATH:" & quoted form of git_path & "; cd " & quoted form of _path & "; " & "git log -1 --date=short --format=format:'\\newcommand{\\RevisionInfo}{Revision %h on %ad}'"
	on error number 128
		error "Cannot find git revision information. Check that the file is inside a repository." number 5033
	end try
	set typeset_lib's gitinfo to _info
	tell typeset_lib to typeset()
end main

try
	main()
on error eStr number eNum partial result rList from badObj to exptectedType
	if eNum = 5033 then
		display dialog eStr buttons {"OK"} with title "Error" default button 1
	else if eNum = 5088 then
		beep
	else if eNum is not -128 then
		error eStr number eNum partial result rList from badObj to exptectedType
	end if
end try

on path_to_contents()
	--- Returns path to "Contents" folder containing the current script
	local delims, split_string
	set delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/Contents/"
	set split_string to text items of POSIX path of (path to me)
	set AppleScript's text item delimiters to delims
	if length of split_string = 1 then error "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." number 5033
	return (item 1 of split_string) & "/Contents/"
end path_to_contents
