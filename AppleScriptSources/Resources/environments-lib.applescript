(* By Nathan Grigg
   Library balance a latex environment
*)

on balance_environment given ending:endBool
	(* "balance_environment with ending" finds the innermost
			environment containing the cursor
	   "balance_envoronment wihtout ending" finds the innermost
	   		incomplete (i.e. without ending tag) environment
	   		containing the cursor
	   	both return {environment_name, begin_offset, end_offset, cursor_offset, document}
	   	end_offset will be missing value in without ending case
	*)

	set _doc to get_front_BBEdit_doc()

	tell application "BBEdit"
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

		set num_chars to length of text of _doc
		if begin_loc > num_chars then set begin_loc to num_chars

		(* begin_loc tracks the first begin, which progress toward the beginning
			 of the document as the outer loop progresses.
		   nested_begin_loc tracks nested begins, which progress toward the
		     end of the document as the inner loop progresses.
		   end_loc tracks the nested ends
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
				error "Cannot find a '\\begin' command" number 5088
			end if

			-- search for end environment, accounting for nesting
			-- continues until the next begin{env} is after the next end{env}
			repeat
				set match_nested_begin to find "\\\\begin{" & _env & "}" searching in characters (nested_begin_loc + 1) through -1 of _doc
				set match_end to find "\\\\end{" & _env & "}" searching in characters (end_loc + 1) through -1 of _doc

				if found of match_end then
					set end_loc to characterOffset of found object of match_end
				else
					if endBool then
						error "Found '\\begin{" & _env & "}' but no '\\end{" & _env & "}'." number 5088
					else
						return {_env, begin_loc, missing value, _cursor, _doc}
					end if
				end if

				if found of match_nested_begin then
					set nested_begin_loc to characterOffset of found object of match_nested_begin
				else
					exit repeat
				end if

				if nested_begin_loc > end_loc then exit repeat
			end repeat

			set end_loc to end_loc + (length of found object of match_end) - 1

			if end_loc is greater than or equal to _cursor and _cursor is greater than or equal to begin_loc then exit repeat
		end repeat
	end tell
	if endBool then
		return {_env, begin_loc, end_loc, _cursor, _doc}
	else
		error "All environments are balanced" number 5088
	end if
end balance_environment


on change_environment(begin_loc, end_loc, doc, cursor_loc, new_env, old_env)
	set _diff to (length of new_env) - (length of old_env)
	tell application "BBEdit"
		set characters (begin_loc + 7) through (begin_loc + 6 + (length of old_env)) of doc to new_env
		set characters (end_loc - (length of old_env) + _diff) through (end_loc - 1 + _diff) of doc to new_env

		-- move cursor to account for inserted characters
		select insertion point before character (cursor_loc + _diff) of doc
	end tell
end change_environment




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
