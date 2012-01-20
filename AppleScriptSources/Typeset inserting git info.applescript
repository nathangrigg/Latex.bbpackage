-- get file information
tell application "BBEdit"
	set _doc to front document
	set _filename to file of _doc
	
	-- exit if not a TeX file
	if source language of _doc is not "TeX" then
		set _result to display dialog "You are attempting to typeset a non-tex file." buttons {"Quit", "Continue"} default button "Quit"
		if button returned of _result is "Quit" then
			return
		end if
	end if
end tell

-- get revision information from git
set AppleScript's text item delimiters to "/"
set _path to text items 1 thru -2 of POSIX path of _filename as string
set AppleScript's text item delimiters to ""
set _info to do shell script "cd " & quoted form of _path & "; " & "git log -1 --date=short --format=format:'\\newcommand{\\RevisionInfo}{Revision %h on %ad}'"

-- insert into file
tell application "BBEdit"
	set _line to make new word at beginning of text of _doc with data _info & return
	save _doc
end tell

tell application "TeXShop"
	set _texdoc to open _filename
	tell _texdoc
		typesetinteractive
		repeat while not (taskdone)
			delay 0.25
		end repeat
	end tell
end tell

--delete the added stuff
set text of _line to ""
save _doc