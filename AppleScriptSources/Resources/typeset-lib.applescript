-- by Nathan Grigg

-- User configurable varaibles
property texbin : "/usr/texbin"
property gitbin : "/usr/local/bin"
property viewer : "Skim"

on typeset given synctex:synctexBool, gitinfo:gitinfoBool
	-- save text item delimiters
	global _delims, _resources
	set _delims to AppleScript's text item delimiters
	set _resources to path_to_contents() & "Resources/"

	tell application "BBEdit"
		-- Get document info and save
		try
			set _doc to document 1
		on error number -1728
			error "There is no open BBEdit document" number 5033
		end try

		set _tex_position to startLine of selection
		save _doc
		if source language of _doc is not "TeX" then
			set _dialog to display dialog "You are attempting to typeset a non-tex file." buttons {"Quit", "Continue"} default button "Quit"
			if button returned of _dialog is "Quit" then return
		end if

		--get the filename of the document
		set _file to file of _doc
		if _file is missing value then error "Cannot access filename of document. It may be on a remote machine or in a zip file." number 5033
		set _filename to POSIX path of (_file as alias)
	end tell

	set {_filename, _tex_program} to extract_directives out of _filename

	-- split folder from basename
	set AppleScript's text item delimiters to "/"
	set _folder to "/" & (text items 1 thru -2 of _filename as string)
	set _basename to last text item of _filename
	set AppleScript's text item delimiters to _delims

	-- get git info if requested
	if gitinfoBool then
		set script_suffix to "'" & (git_log for _folder) & " \\input{\"" & _basename & "\"}'"
	else
		set script_suffix to quoted form of _basename
	end if

	-- run the pdflatex script
	try
		do shell script "PATH=$PATH:" & quoted form of texbin & " ; cd " & quoted form of _folder & " ; " & _tex_program & " -interaction=batchmode -synctex=1 " & script_suffix
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
			error "Latex command returned an error, but no errors are found in the log.\r\r" & errMsg number 5033
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
					if not found of result then tell _doc to select line (result_line of _err)
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
		try
			-- check that Skim exists and get its path
			tell application "Finder" to set skim_path to POSIX path of (application file id "SKim" as alias)
		on error
			do shell script "open -g -a Preview " & quoted form of _pdf
			return
		end try

		if synctexBool then
			try
				do shell script quoted form of skim_path & "Contents/SharedSupport/displayline -r -b -g " & _tex_position & " " & quoted form of _pdf & " " & quoted form of _filename
			on error
				skim_reload(_pdf)
			end try
		else
			skim_reload(_pdf)
		end if
	else
		do shell script "open -g -a " & quoted form of viewer & " " & quoted form of _pdf
	end if
end typeset


on git_log for _folder
	-- get revision information from git
	try
		set _info to do shell script "PATH=$PATH:" & quoted form of gitbin & "; cd " & quoted form of _folder & "; " & "git log -1 --date=short --format=format:'\\newcommand{\\RevisionInfo}{Revision %h on %ad}'"
	on error number 128
		error "Cannot find git revision information. Check that the file is inside a repository." number 5033
	end try
	return _info
end git_log

on extract_directives out of _filename
	--look in beginning of file for directives (e.g. "% !TEX program=xelatex")
	global _resources
	try
		set _result to do shell script quoted form of (_resources & "directives.py") & " root program " & quoted form of _filename
	on error errMsg
		error "Error extracting directives from file (python script directives.py)\r\r" & errMsg number 5033
	end try

	-- grab the root document name
	set _filename to paragraph 1 of _result

	-- grab the latex engine
	set _line to paragraph 2 of _result
	if _line is "" then
		set _tex_program to "pdflatex"
	else
		set _tex_program to _line
	end if
	return {_filename, _tex_program}
end extract_directives

on skim_reload(_pdf)
	-- this monstrosity allows the rest of the script to work even if Skim is not installed.
	do shell script "/usr/bin/osascript -e 'tell application \"Skim\"' -e 'set _window to open \"" & _pdf & "\"' -e 'revert _window' -e 'end tell'"
end skim_reload

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
