-- Title for all the dialog boxes
set _title to "Declare Math Operator"
tell application "BBEdit"
	
	set _doc to front document
	set _cursor_position to selection
	set _options to {search mode:literal, starting at top:true, wrap around:false, backwards:false, case sensitive:true, match words:false, extend selection:false}
	
	--Find place where we are going to insert stuff
	-- search for other DeclareMathOperators	
	set _found to find "\\DeclareMathOperator" searching in text 1 of _doc options _options
	
	if found of _found then
		set _text to "\\DeclareMathOperator"
		set _newline to return
	else
		--can't find DeclareMathOperator, look for \begin{document}
		set _found to find "\\begin{document}" searching in text 1 of _doc options _options
		if found of _found then
			set _text to "\\begin{document}"
			set _newline to return & return
		else
			--can't find begin document
			display dialog "I could not find the \\begin{document} command, so I do not know where the preamble ends. I am unable to continue." with title _title buttons {"Quit"} default button "Quit"
			--exit
			return
		end if
	end if
	set _location to found object of _found
end tell

-- ask for name of command
try
	set _result to display dialog "Name of command (e.g. \\sin)" with title _title default answer ""
	set _command_name to text returned of _result
on error "User canceled."
	-- quit if canceled
	return
end try

-- Check to make sure this math operator has not been defined in this document
tell application "BBEdit"
	set _found to find "\\DeclareMathOperator{" & _command_name & "}" searching in text 1 of _doc options _options
	if found of _found then
		display dialog "The math operator " & _command_name & " is already delcared." with title _title buttons {"Quit"} default button "Quit"
		--exit
		return
	end if
end tell

-- Now get the text of the math operator
-- use the command name with the first character removed as a guess
set _guess to characters 2 through end of _command_name as string
try
	set _result to display dialog "Text of the math operator (e.g. sin)" with title _title default answer _guess
	set _command_text to text returned of _result
on error "User canceled."
	return
end try

--do the replacement
tell application "BBEdit"
	set _insert_new to "\\DeclareMathOperator{" & _command_name & "}{" & _command_text & "}" & _newline
	set _insert_old to _text
	set _insert_length to length of _insert_new
	set text of _location to _insert_new & _insert_old
	
	set _offset to characterOffset of _cursor_position
	set _length to length of _cursor_position
	
	if _length = 0 then
		select insertion point before character (_offset + _insert_length) of _doc
	else
		select characters (_offset + _insert_length) thru (_offset + _insert_length + _length - 1) of _doc
	end if
end tell
