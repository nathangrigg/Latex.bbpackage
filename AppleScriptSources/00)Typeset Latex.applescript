-- user configurable varaibles
set texbin to "/usr/texbin"
set viewer to "Skim"


-- save text item delimiters
set _delims to AppleScript's text item delimiters

-- Get path to scripts
tell application "Finder"
	set _resources to (POSIX path of ((container of (container of (path to me))) as text)) & "Resources/"
	try
		do shell script "ls " & quoted form of _resources
	on error
		display dialog "Unable to get the \"Resources\" folder of the Latex BBEdit package. For example, this will happen if you move scripts around inside the package." buttons {"Quit"} default button "Quit"
		return
	end try
end tell

tell application "BBEdit"
	-- Get document info and save
	try
		set _doc to document 1
	on error
		display dialog "I cannot find an open BBEdit document" buttons {"Quit"} default button "Quit"
		return
	end try
	set _tex_position to startLine of selection
	save _doc
	if source language of _doc is not "TeX" then
		set _dialog to display dialog "You are attempting to typeset a non-tex file." buttons {"Quit", "Continue"} default button "Quit"
		if button returned of _dialog is "Quit" then
			return
		end if
	end if

	--get the filename of the document
	set _filename to POSIX path of (file of _doc as string)
end tell

--look in beginning of file for directives (e.g. "% !TEX program=xelatex")
try
	set _result to do shell script quoted form of (_resources & "directives.py") & " root program " & quoted form of _filename
on error
	display dialog "Error extracting directives from file (python script directives.py)"
	return
end try

-- grab the root document name and gret  folder and basename
set _line to paragraph 1 of _result
set _filename to _line

set AppleScript's text item delimiters to "/"
set _folder to "/" & (text items 1 thru -2 of _filename as string)
set _basename to last text item of _filename
set AppleScript's text item delimiters to _delims

-- grab the latex engine
set _line to paragraph 2 of _result
if _line is "" then
	set _tex_program to "pdflatex"
else
	set _tex_program to _line
end if

try
	-- run latex
	do shell script "cd " & quoted form of _folder & " ; " & texbin & "/" & _tex_program & " -interaction=batchmode -synctex=1 " & quoted form of _basename
on error

	set AppleScript's text item delimiters to "."
	set _logfile to ((text items 1 thru -2 of _filename) as string) & ".log" as string
	set AppleScript's text item delimiters to _delims

	-- time to run the log parsing script

	try
		set _result to do shell script quoted form of (_resources & "parse_log.py") & " " & (quoted form of _logfile)
	on error
		display dialog "Error parsing the log file. It may not exist (parse_log.py)"
		return
	end try

	if _result is "" then
		display dialog "Latex command returned an error, but no errors are found in the log. (command: " & texbin & "/" & _tex_program & ")"
		return
	end if

	tell application "BBEdit"
		set err_list to {}
		repeat with _err in (every paragraph of _result)
			if (_err as text) is not equal to "" then
				try
					if (word 1 of _err) is "Error" then
						set _kind to error_kind
					else if (word 1 of _err) is "Warning" then
						set _kind to warning_kind
					else
						set _kind to "Unknown"
					end if
				on error
					set _kind to "Unknown"
				end try

				if _kind is not "Unknown" then
					set AppleScript's text item delimiters to {tab}
					set _filename to text item 2 of _err
					try
						set _file to POSIX file _filename as alias
					on error
						display dialog "The log referenced an unknown file."
						return
					end try
					set _line to text item 3 of _err
					set _description to text items 4 thru -1 of _err as text
					set AppleScript's text item delimiters to _delims
					try
						set line_num to _line as integer
					on error
						set line_num to 0
					end try

					set err_list_item to {result_kind:_kind, result_line:line_num, message:_description, result_file:_file}
					copy err_list_item to end of err_list

				end if
			end if
		end repeat

		set _err to item 1 of err_list

		try
			set _dialog to display dialog "Error: " & message of _err buttons {"Go to Error", "See all errors", "Cancel"} default button 1 with title "Error in typesetting"
		on error
			return
		end try

		if button returned of _dialog is "Go to Error" then
			set _doc to open result_file of _err
			tell _doc to select line (result_line of _err)
			return

		else
			make new results browser with data err_list with properties {name:"Log Warnings and Errors"}
			return
		end if
	end tell
end try

set AppleScript's text item delimiters to "."
set _pdf to ((text items 1 thru -2 of _filename) as string) & ".pdf" as string
set AppleScript's text item delimiters to _delims

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
