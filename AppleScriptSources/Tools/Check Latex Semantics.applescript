-- set this to the location of chktex
property texbin: "/usr/texbin/"

(*
ChkTeX for BBEdit
Ram—n M. Figueroa-Centeno
http://www2.hawaii.edu/~ramonf

Version: 1.2
Date: October 12, 2007

This AppleScript is released under a Creative Commons Attribution-ShareAlike License:
<http://creativecommons.org/licenses/by-sa/2.0/>

Based on the CSS Syntax Check script for BBEdit by John Gruber:
http://daringfireball.net/projects/csschecker/

*)

on run
	-- The run handler is called when the script is invoked normally,
	-- such as from BBEdit's Scripts menu.
	my ChkteX()
end run

on menuselect()
	-- The menuselect() handler gets called when the script is invoked
	-- by BBEdit as a menu script. Save this script, or an alias to it,
	-- as "Check¥Document Syntax" in the "Menu Scripts" folder in your
	-- "BBEdit Support" folder.
	tell application "BBEdit"
		-- returning true value stops action from continuing
		-- false makes the menu action continue
		try
			if (source language of window 1 is "TeX") then
				-- It's a TeX file, so tell BBEdit *not* to
				-- continue with its HTML syntax check:
				my ChkteX()
				return true
			else
				return false
			end if
		end try
	end tell
end menuselect

on ChkteX()
	tell application "BBEdit"
		try
			if not (on disk of active document of text window 1) then
				beep
				display dialog "You need to save your document!" buttons {"OK"} default button 1 with icon stop
				return
			end if
		on error
			beep
			return
		end try
		if (modified of active document of text window 1) then
			beep
			display dialog "You need to save changes to your document!" buttons {"Cancel", "Save"} default button 2 with icon caution
		end if
		set properties of active document of text window 1 to {line breaks:Unix}
		save active document of text window 1
		set texFile to file of active document of text window 1
		set texFileName to the name of the active document of text window 1
		if the source language of the active document of text window 1 is not "TeX" then
			display dialog "The source language of the document is not ÒTeXÓ!" buttons {"Sorry"} default button 1 with icon stop
			return
		end if

		(*
             if texFileName does not end with ".tex" then
			display dialog "Not a .tex file!" buttons {"Sorry"} default button 1 with icon stop
			return true
		end if
            *)

	end tell
	set texFileDir to do shell script "dirname " & the quoted form of the (POSIX path of texFile as string)

	if texFile is "" then return -- Don't proceed if we don't have a path to the file

	set newline to ASCII character 10

	(*	ChkTeX can be told to use a custom format with the option -f followed by a string of these:

		%b String to print between fields (from -s option).
		%c Column position of error.
		%d Length of error (digit).
		%f Current file name.
		%i Turn on inverse printing mode.
		%I Turn off inverse printing mode.
		%k kind of error (warning, error, message).
		%l line number of error.
		%m Warning message.
		%n Warning number.
		%u An underlining line (like the one which appears when using Ò-v1Ó).
		%r Part of line in front of error (ÔSÕ - 1).
		%s Part of line which contains error (string).
		%t Part of line after error (ÔSÕ + 1).
*)

	set command to "PATH=$PATH:" & quoted form of texbin & " ; cd " & quoted form of texFileDir & " ; "
	set command to command & "chktex -q -f \"%k%b%l%b%m%b%f%b%c%b%s"
	set command to command & newline & "\" " & quoted form of texFileName
	try
		set check_result to do shell script command
	on error err_text number err_num
		display dialog err_text
	end try

	set critic_error_list to {}

	tell application "BBEdit"
		if check_result is "" then
			set document_name to name of document of text window 1
			display alert "ChkTeX OK" message "No ChkTeX warnings were found in Ò" & document_name & "Ó."
			return
		end if

		-- Put together the results for the browser:
		repeat with err in (every paragraph of check_result)
			if (err as text) is not equal to "" then

				set old_delims to AppleScript's text item delimiters
				set AppleScript's text item delimiters to {":"}

				set kind_of_error to text item 1 of err
				if kind_of_error is "Error" then
					set err_kind to error_kind
				else if kind_of_error is "Warning" then
					set err_kind to warning_kind
				else if kind_of_error is "Message" then
					set err_kind to note_kind
				end if

				set line_num to text item 2 of err as integer

				set err_description to text item 3 of err

				set name_of_file to text item 4 of err as string

				set file_path to (texFileDir & "/" & name_of_file)

				-- The following breaks if we let BBEdit do it?!
				tell me to set the current_file to POSIX file file_path

				set error_string_length to length of (text item 6 of err as string)

				set before_error to (text item 5 of err as integer)

				set AppleScript's text item delimiters to old_delims

				-- We compute the offset of the line under consideration; if the line is in the open
				-- document we use BBEdit to get this offset, otherwise if the line is in an auxiliary
				-- file (loaded via \input) we use a shell script. The auxiliary file must have
				-- UNIX file endings (endline).

				if name_of_file = texFileName then
					set line_offset to (characterOffset of line line_num of the active document of text window 1)
				else
					tell me
						set line_offset to ((do shell script "head -n " & (line_num - 1) & " " & file_path & " | wc -m") as integer) + 1
					end tell
				end if

				set start_error to line_offset + before_error - 2
				set end_error to start_error + error_string_length

				set err_list_item to {result_kind:err_kind, result_file:current_file, result_line:line_num, message:err_description as text, start_offset:start_error, end_offset:end_error}

				copy err_list_item to end of critic_error_list
			end if
		end repeat

		try
			close window "ChkTeX Warnings"
		end try

		make new results browser with data critic_error_list with properties {name:"ChkTeX Warnings"}

	end tell

end ChkteX
