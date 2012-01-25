-- Get path to scripts
try
	set _path to term(POSIX path of (path to me), "/Contents/")
on error
	display dialog "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." buttons {"Quit"} default button "Quit"
	return
end try
set _resources to _path & "Resources/"

try
	do shell script "ls " & quoted form of _resources
on error
	display dialog "Unable to get the \"Resources\" folder of the Latex BBEdit package. For example, this will happen if you move scripts around inside the package." buttons {"Quit"} default button "Quit"
	return
end try

-- save text item delimiters
set _delims to AppleScript's text item delimiters

tell application "BBEdit"
	-- Get document info and save
	try
		set _file to (file of document 1)
		set _filename to POSIX path of _file
	on error
		display dialog "I cannot get the filename of any document."
		return
	end try

	try
		set _filename to do shell script quoted form of (_resources & "directives.py") & " root " & quoted form of _filename
	on error errMsg
		display dialog "Error extracting directives from the file (python script directives.py)" & return & return & errMsg
		return
	end try

	set AppleScript's text item delimiters to "."
	set _logfile to ((text items 1 thru -2 of _filename) as string) & ".log" as string
	set AppleScript's text item delimiters to _delims

	-- time to run the log parsing script

	try
		set _result to do shell script quoted form of (_resources & "parse_log.py") & " --errors --warnings --refs --boxes " & quoted form of _logfile
	on error
		display dialog "Error parsing the log file. It may not exist (parse_log.py)"
		return
	end try

	if _result is "" then
		display dialog "There are no errors" buttons {"OK"} default button {"OK"}
		return
	end if

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
				set _delims to AppleScript's text item delimiters
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

	make new results browser with data err_list with properties {name:"Log Warnings and Errors"}

end tell

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return text 1 thru (_l + _n - 1) of str
end term
