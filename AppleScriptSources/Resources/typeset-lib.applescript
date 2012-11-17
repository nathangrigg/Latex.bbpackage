-- by Nathan Grigg

-- User configurable variables
property texbin : "/usr/texbin"
property gitbin : "/usr/local/bin"
property viewer : "Skim"

------ Main typeset script ------

on typeset given synctex:synctexBool, gitinfo:gitinfoBool
	(* typeset the front BBEdit document and display the pdf
	   use "with synctex" to use forward search in Skim
	   use "with gitinfo" to add latest git commit information
	*)

	set resource_path to path_to_contents() & "Resources/"
	set doc to get_front_BBEdit_doc()

	tell application "BBEdit"
		set tex_position to startLine of selection
		save doc
		if source language of doc is not "TeX" then
			display dialog "You are attempting to typeset a non-tex file." buttons {"Quit", "Continue"} default button "Quit"
			if button returned of result is "Quit" then return false
		end if
	end tell

	set filename to get_filename for doc
	set {root, tex_program} to extract_directives out of filename

	-- split folder from basename
	set delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/"
	set root_folder to "/" & (text items 1 thru -2 of root as string)
	set root_base to last text item of root
	set AppleScript's text item delimiters to delims

	-- get git info if requested
	if gitinfoBool then
		set script_suffix to "'" & (git_log for root_folder) & " \\input{\"" & root_base & "\"}'"
	else
		set script_suffix to quoted form of root_base
	end if

	-- run the pdflatex script
	try
		do shell script "PATH=$PATH:" & quoted form of texbin & " ; cd " & quoted form of root_folder & " ; " & tex_program & " -interaction=batchmode -synctex=1 " & script_suffix
	on error errMsg number errNum
		if errNum is 127 then command_not_found(tex_program)
		handle_latex_error from root given errMessage:errMsg
		return false
	end try

	view_pdf of root given synctex:synctexBool, tex_program:tex_program, synctex_line:tex_position, synctex_file:filename
	return true
end typeset

------ Extract directives ------

on extract_directives out of filename
	--look in beginning of file for directives (e.g. "% !TEX program=xelatex")
	set resource_path to path_to_contents() & "Resources/"
	try
		set shell_result to do shell script quoted form of (resource_path & "directives.py") & " root program " & quoted form of filename
	on error errMsg
		error "Error extracting directives from file (python script directives.py)\r\r" & errMsg number 5033
	end try

	-- grab the root document name
	set filename to paragraph 1 of shell_result

	-- grab the latex engine
	set tex_program to paragraph 2 of shell_result
	if tex_program is "" then set tex_program to "pdflatex"

	return {filename, tex_program}
end extract_directives


------ Git info ------

on git_log for folder_name
	-- get revision information from git
	try
		set git_info to do shell script "PATH=$PATH:" & quoted form of gitbin & "; cd " & quoted form of folder_name & "; " & "git log -1 --date=short --format=format:'\\newcommand{\\RevisionInfo}{Revision %h on %ad}'"
	on error errMsg number errNum
		if errNum is 127 then
			command_not_found("git")
		else if errNum is 128 then
			error errMsg number 5033
		else
			error errMsg number errNum
		end if
	end try
	return git_info
end git_log

------ Latex error handling ------

on parse_errors from filename given warnings:warningsBool
	(* Parse errors from log associated to filename
	   use "with warnings" to also parse warnings
	   use "without warnings" to parse errors only
	*)
	set resource_path to path_to_contents() & "Resources/"
	-- parse errors from logfile and create a results browser
	set log_file to change_extension of filename into "log"

	if warningsBool then
		set parse_options to " --errors --warnings --refs --boxes "
	else
		set parse_options to " "
	end if

	try
		set shell_result to do shell script quoted form of (resource_path & "parse_log.py") & parse_options & (quoted form of log_file)
	on error
		error "Error parsing the log file. It may not exist (parse_log.py)" number 5033
	end try

	set err_list to {}
	repeat with err in (every paragraph of shell_result)
		if (err as text) is not equal to "" then
			try
				tell application "BBEdit"
					if (word 1 of err) is "Error" then
						set kind_of_result to error_kind
					else if (word 1 of err) is "Warning" then
						set kind_of_result to warning_kind
					else
						set kind_of_result to "Unknown"
					end if
				end tell
			on error
				set kind_of_result to "Unknown"
			end try

			if kind_of_result is not "Unknown" then
				set delims to AppleScript's text item delimiters
				set AppleScript's text item delimiters to {tab}
				set filename to text item 2 of err
				try
					set error_file to POSIX file filename as alias
				on error
					error "The log referenced an unknown file." number 5033
				end try
				set error_line_str to text item 3 of err
				set error_description to text items 4 thru -1 of err as text
				set AppleScript's text item delimiters to delims
				try
					set error_line to error_line_str as integer
				on error
					set error_line to 0
				end try

				tell application "BBEdit" to set err_list_item to {result_kind:kind_of_result, result_line:error_line, message:error_description, result_file:error_file}
				copy err_list_item to end of err_list
			end if
		end if
	end repeat
	return err_list
end parse_errors

on handle_latex_error from filename given errMessage:errMsg
	-- handle an error in the latex shell command
	set err_list to parse_errors from filename without warnings
	if length of err_list is 0 then error "Latex command returned an error, but no errors are found in the log.\r\r" & errMsg number 5033

	tell application "BBEdit"
		set err to item 1 of err_list
		-- Errors that aren't line-based have a line number 0
		-- We don't want to move the cursor unless the there is a
		-- positive line
		if (result_line of err) > 0 then
			set button_text to "Go to Error"
		else
			set button_text to "OK"
		end if

		set err_dialog to display dialog "Error: " & message of err buttons {"See all errors", "Cancel", button_text} default button 3 with title "Error in typesetting"

		if button returned of err_dialog is "Go to Error" then
			set doc to open result_file of err
			-- special handling of undefined control sequence
			-- be a little careful to escape the backslash for BBEdit
			if message of err begins with "Undefined control sequence \\" then
				find ("\\\\" & text 29 through -2 of (message of err)) searching in line (result_line of err) of doc with selecting match
				if not found of result then tell doc to select line (result_line of err)
			else
				tell doc to select line (result_line of err)
			end if
		else if button returned of err_dialog is "See all errors" then
			make new results browser with data err_list with properties {name:"Log Warnings and Errors"}
		end if
	end tell
end handle_latex_error

------ PDF subroutines ------

on view_pdf of filename given synctex:synctexBool, tex_program:tex, synctex_line:s_line, synctex_file:s_file
	(* View pdf in Skim or some other viewer
	   The extension of filename doesn't matter; it is changed intelligently.
  	   Use tex_program:"pdflatex" to specify the tex program
	     (this is used to determine if the extension is pdf or dvi)
	   Use "with synctex" to use forward search (for Skim only)
	   Use "given synctex_line:10, synctex_file:blah.tex" to give
	     additional synctex information.
	   Set the viewer property to use a different viewer program.
	   If Skim is not installed but the viewer is set to Skim, it
	     uses Preview instead.
	*)

	if {"tex", "etex", "eplain", "latex", "dviluatex", "dvilualatex", "xmltex", "jadetex", "mtex", "utf8mex", "cslatex", "csplain", "aleph", "lamed"} contains tex then
		set extension to "dvi"
	else
		set extension to "pdf"
	end if

	set pdf to change_extension of filename into extension
	-- test for existence of pdf file
	try
		POSIX file pdf as alias
	on error number -1700
		error "File " & pdf & " does not exist." number 5033
	end try

	if viewer is "Skim" then
		try
			-- check that Skim exists and get its path
			tell application "Finder" to set skim_path to POSIX path of (application file id "SKim" as alias)
		on error
			do shell script "open -g -a Preview " & quoted form of pdf
			return
		end try

		if synctexBool then
			try
				do shell script quoted form of skim_path & "Contents/SharedSupport/displayline -r -b -g " & s_line & " " & quoted form of pdf & " " & quoted form of s_file
			on error
				skim_reload(pdf)
			end try
		else
			skim_reload(pdf)
		end if
	else
		do shell script "open -g -a " & quoted form of viewer & " " & quoted form of pdf
	end if
end view_pdf

on skim_reload(pdf)
	-- this monstrosity allows the rest of the script to work even if Skim is not installed.
	do shell script "/usr/bin/osascript -e 'tell application \"Skim\"' -e 'set doc to open \"" & pdf & "\"' -e 'if doc is not missing value then revert doc' -e 'end tell'"
end skim_reload

------ Get information from BBEdit ------
on get_front_BBEdit_doc()
	-- get front document, with error if there is none
	try
		tell application "BBEdit" to set doc to document 1
	on error number -1728
		error "There is no open BBEdit document" number 5033
	end try
	return doc
end get_front_BBEdit_doc

on get_filename for doc
	-- get filename from BBEdit document object, with error on missing value
	tell application "BBEdit" to set doc_file to file of doc
	if doc_file is missing value then error "Cannot access filename of document.\r\rCheck that it is saved on your local machine and not inside a zip file." number 5033
	return POSIX path of (doc_file as alias)
end get_filename

------ String manipulation subroutines ------

on change_extension of filename into ext
	-- return filename with extension changed to ext
	set delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "."
	set new_name to ((text items 1 thru -2 of filename) & ext) as string
	set AppleScript's text item delimiters to delims
	return new_name
end change_extension

on command_not_found(command_name)
	error "Shell command not found: " & command_name number 5033
end command_not_found

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
