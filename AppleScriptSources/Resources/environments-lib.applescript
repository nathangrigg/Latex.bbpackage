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

	set doc to get_front_BBEdit_doc()

	tell application "BBEdit"
		set cursor_loc to characterOffset of selection

		-- This is so if your cursor is \begin{equ|ation} it will still work.
		try
			set match_loc to find "\\w*{?\\w*\\*?}" searching in characters cursor_loc through -1 of doc options {search mode:grep}
			if found of match_loc and (characterOffset of found object of match_loc) is cursor_loc then
				set begin_loc to cursor_loc + (length of found object of match_loc)
			else
				set begin_loc to cursor_loc
			end if
		on error
			set begin_loc to cursor_loc
		end try

		set num_chars to length of text of doc
		if begin_loc > num_chars then set begin_loc to num_chars

		(* begin_loc tracks the first begin, which progress toward the beginning
			 of the document as the outer loop progresses.
		   nested_begin_loc tracks nested begins, which progress toward the
		     end of the document as the inner loop progresses.
		   end_loc tracks the nested ends
		*)
		repeat

			-- Search backwards to previous begin and extract environment name
			set match_begin to find "\\\\begin{([^}]*)}" searching in characters 1 through begin_loc of doc options {search mode:grep, backwards:true}

			if found of match_begin then
				set env to grep substitution of "\\1"
				set begin_loc to characterOffset of found object of match_begin
				set nested_begin_loc to begin_loc
				set end_loc to begin_loc
			else
				error "Cannot find a '\\begin' command" number 5088
			end if

			-- search for end environment, accounting for nesting
			-- continues until the next begin{env} is after the next end{env}
			repeat
				set match_nested_begin to find "\\\\begin{" & env & "}" searching in characters (nested_begin_loc + 1) through -1 of doc
				set match_end to find "\\\\end{" & env & "}" searching in characters (end_loc + 1) through -1 of doc

				if found of match_end then
					set end_loc to characterOffset of found object of match_end
					-- When looking for match without ending, don't go past cursor location
					if not endBool and end_loc > cursor_loc then
						return {env, begin_loc, missing value, cursor_loc, doc}
					end if
				else
					if endBool then
						error "Found '\\begin{" & env & "}' but no '\\end{" & env & "}'." number 5088
					else
						return {env, begin_loc, missing value, cursor_loc, doc}
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

			if end_loc is greater than or equal to cursor_loc and cursor_loc is greater than or equal to begin_loc then exit repeat
		end repeat
	end tell
	if endBool then
		return {env, begin_loc, end_loc, cursor_loc, doc}
	else
		error "All environments are balanced" number 5088
	end if
end balance_environment


on change_environment(begin_loc, end_loc, doc, cursor_loc, new_env, old_env)
	set diff to (length of new_env) - (length of old_env)
	tell application "BBEdit"
		set characters (begin_loc + 7) through (begin_loc + 6 + (length of old_env)) of doc to new_env
		set characters (end_loc - (length of old_env) + diff) through (end_loc - 1 + diff) of doc to new_env

		-- move cursor to account for inserted characters
		select insertion point before character (cursor_loc + diff) of doc
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
