-- by Nathan Grigg

-- User configurable varaibles
property texbin : "/usr/texbin"
property viewer : "Skim"
property synctex : false

-- Don't change this
property gitinfo : ""

-- Do the typsetting
typeset()

-- Function typset()

on typeset()
	-- save text item delimiters
	set _delims to AppleScript's text item delimiters

	-- Get path to scripts
	try
		set _path to term(POSIX path of (path to me), "/Contents/")
	on error
		display dialog "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." buttons {"Quit"} default button "Quit"
		return
	end try

	set _resources to _path & "Resources/"

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
	on error errMsg
		display dialog "Error extracting directives from file (python script directives.py)" & return & return & errMsg
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
		-- this is the standard typeset
		if gitinfo is "" then
			do shell script "PATH=$PATH:" & quoted form of texbin & " ; cd " & quoted form of _folder & " ; " & _tex_program & " -interaction=batchmode -synctex=1 " & quoted form of _basename
		else
			-- this is typeset adding git info
			do shell script "PATH=$PATH:" & quoted form of texbin & " ; cd " & quoted form of _folder & " ; " & _tex_program & " -interaction=batchmode -synctex=1 " & "'" & gitinfo & " \\input{\"" & _basename & "\"}'"
		end if
	on error errMsg
		-- if latex returns a nonzero status, check the log for errors
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
			display dialog "Latex command returned an error, but no errors are found in the log." & return & return & errMsg buttons {"Quit"} default button "Quit"
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

			-- Errors that aren't line-based have a line number 0
			-- We don't want to move the cursor unless the there is a
			-- positive line
			if (result_line of _err) > 0 then
				set button_text to "Go to Error"
			else
				set button_text to "OK"
			end if

			try
				set _dialog to display dialog "Error: " & message of _err buttons {"See all errors", "Cancel", button_text} default button 3 with title "Error in typesetting"
			on error
				return
			end try

			if button returned of _dialog is "Go to Error" then
				set _doc to open result_file of _err
				-- special handling of undefined control sequence
				if length of (message of _err) > 26 and text 1 through 26 of (message of _err) is "Undefined control sequence" then
					find (text 28 through -2 of (message of _err)) searching in line (result_line of _err) of _doc with selecting match
					if not found of result then select line (result_line of _err)
				else
					tell _doc to select line (result_line of _err)
				end if
				return

			else if button returned of _dialog is "OK" then
				return
			else
				make new results browser with data err_list with properties {name:"Log Warnings and Errors"}
				return
			end if
		end tell
	end try

	if {"tex", "etex", "eplain", "latex", "dviluatex", "dvilualatex", "xmltex", "jadetex", "mtex", "utf8mex", "cslatex", "csplain", "aleph", "lamed"} contains _tex_program then
		set _extension to ".dvi"
	else
		set _extension to ".pdf"
	end if

	set AppleScript's text item delimiters to "."
	set _pdf to ((text items 1 thru -2 of _filename) as string) & _extension as string
	set AppleScript's text item delimiters to _delims

	if viewer is "Skim" then
		if synctex then

			try
				do shell script "/Applications/Skim.app/Contents/SharedSupport/displayline -r -b -g " & _tex_position & " " & quoted form of _pdf & " " & quoted form of _filename
			on error
				skim_reload(_pdf)
			end try
		else
			skim_reload(_pdf)
		end if
	else
		do shell script "open -a " & quoted form of viewer & " " & quoted form of _pdf
	end if
end typeset

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return text 1 thru (_l + _n - 1) of str
end term

on skim_reload(_filename)
	tell application "Skim"
		set _window to open _filename
		revert _window
	end tell
end skim_reload
