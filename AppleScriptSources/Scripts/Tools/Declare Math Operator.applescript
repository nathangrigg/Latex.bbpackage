-- Title for all the dialog boxes

on main()
	set doc to get_front_BBEdit_doc()
	tell application "BBEdit"
		set cursor_position to selection
		set search_options to {search mode:literal, starting at top:true, wrap around:false, backwards:false, case sensitive:true, match words:false, extend selection:false}

		--Find place where we are going to insert stuff
		-- search for other DeclareMathOperators
		set find_result to find "\\DeclareMathOperator" searching in text 1 of doc options search_options

		if found of find_result then
			set search_text to "\\DeclareMathOperator"
			set newline to "\r"
		else
			--can't find DeclareMathOperator, look for \begin{document}
			set find_result to find "\\begin{document}" searching in text 1 of doc options search_options
			if not found of find_result then error "I could not find the \\begin{document} command, so I do not know where the preamble ends. I am unable to continue." number 5033

			set search_text to "\\begin{document}"
			set newline to "\r\r"
		end if
		set preamble_pos to found object of find_result
	end tell

	-- ask for name of command
	display dialog "Name of command (e.g. \\sin)" with title "Declare Math Operator" default answer ""
	set command_name to text returned of result

	-- Check to make sure this math operator has not been defined in this document
	tell application "BBEdit"
		set find_result to find "\\DeclareMathOperator{" & command_name & "}" searching in text 1 of doc options search_options
		if found of find_result then error "The math operator " & command_name & " is already delcared." number 5033
	end tell

	-- Now get the text of the math operator
	-- use the command name with the first character removed as a guess
	try
		set guess to text 2 through end of command_name
	on error
		set guess to command_name
	end

	display dialog "Text of the math operator (e.g. sin)" with title "Declare Math Operator" default answer guess
	set command_text to text returned of result

	--do the replacement
	tell application "BBEdit"
		set insert_new to "\\DeclareMathOperator{" & command_name & "}{" & command_text & "}" & newline
		set insert_old to search_text
		set insert_length to length of insert_new
		set text of preamble_pos to insert_new & insert_old

		set cursor_offset to characterOffset of cursor_position
		set selection_length to length of cursor_position

		if selection_length = 0 then
			select insertion point before character (cursor_offset + insert_length) of doc
		else
			select characters (cursor_offset + insert_length) thru (cursor_offset + insert_length + selection_length - 1) of doc
		end if
	end tell
end main

-- Catch and display custom errors; exit silently on cancelled dialogs
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
