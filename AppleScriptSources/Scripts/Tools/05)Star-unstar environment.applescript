-- by Nathan Grigg

property delay_time : 0.4

tell application "BBEdit"

	set _doc to text document 1
	-- save cursor location
	set _cursor to characterOffset of selection

	-- This is so if your cursor is \begin{equ|ation} it will still work.
	try
		set _match to find "\\w*{?\\w*\\*?}" searching in characters _cursor through -1 of _doc options {search mode:grep}
		if found of _match and (characterOffset of found object of _match) is _cursor then
			set begin_loc to _cursor + (length of found object of _match)
		else
			set begin_loc to _cursor
		end if
	on error
		set begin_loc to _cursor
	end try

	(*
	  begin_loc tracks the first begin, which progress toward the beginning
	     of the document as the outer loop progresses.
	  nested_begin_loc tracks nested begins, which progress toward the
	     end of the document as the inner loop progresses.
	  end_loc tracks the nested ends, eventually settling on the end that
	     we are looking for
	*)
	repeat

		-- Search backwards to previous begin and extract environment name
		set match_begin to find "\\\\begin{([^}]*)}" searching in characters 1 through begin_loc of _doc options {search mode:grep, backwards:true}

		if found of match_begin then
			set _env to grep substitution of "\\1"
			set begin_loc to characterOffset of found object of match_begin
			set nested_begin_loc to begin_loc
			set end_loc to begin_loc
		else
			my no_match("Need a '\\begin' command before cursor")
			return
		end if

		-- search for end environment, accounting for nesting
		-- continues until the next begin{env} is after the next end{env}
		repeat
			set match_nested_begin to find "\\\\begin{" & _env & "}" searching in characters (nested_begin_loc + 1) through -1 of _doc
			set match_end to find "\\\\end{" & _env & "}" searching in characters (end_loc + 1) through -1 of _doc

			if found of match_end then
				set end_loc to characterOffset of found object of match_end
			else
				my no_match("Found '\\begin{" & _env & "}' but no '\\end{" & _env & "}'.")
				return
			end if

			if found of match_nested_begin then
				set nested_begin_loc to characterOffset of found object of match_nested_begin
			else
				exit repeat
			end if

			if nested_begin_loc > end_loc then exit repeat
		end repeat

		set end_loc to end_loc + (length of found object of match_end) - 1

		if end_loc ≥ _cursor and _cursor ≥ begin_loc then exit repeat
	end repeat

	select characters begin_loc through end_loc of _doc

	delay delay_time

	if last character of _env is "*" then
		set new_env to text 1 through -2 of _env
		set _diff to -1
	else
		set new_env to _env & "*"
		set _diff to 1
	end if

	set characters (begin_loc + 7) through (begin_loc + 6 + (length of _env)) of _doc to new_env
	set characters (end_loc - (length of _env) + _diff) through (end_loc - 1 + _diff) of _doc to new_env

	select insertion point before character (_cursor + _diff) of _doc
end tell

on no_match(msg)
	beep
	-- error msg
end no_match
