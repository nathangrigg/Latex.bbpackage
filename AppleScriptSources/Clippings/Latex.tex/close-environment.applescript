-- by Nathan Grigg

on run
	tell application "BBEdit"
		set _doc to text document 1
		set _cursor to characterOffset of selection

		set begin_loc to _cursor
		(*
	 	begin_loc tracks the first begin, which progress toward the beginning
	     		of the document as the outer loop progresses.
		nested_begin_loc tracks nested begins, which progress toward the
			end of the document as the inner loop progresses.
	  	end_loc tracks the nested ends
		*)
		repeat

			-- Search backwards to previous begin and extract environment name
			try
				set match_begin to find "\\\\begin{([^}]*)}" searching in characters 1 through begin_loc of _doc options {search mode:grep, backwards:true}
			on error
				set match_begin to find "\\\\begin{([^}]*)}" searching in text 1 of _doc options {search mode:grep, backwards:true}
			end try

			if found of match_begin then
				set _env to grep substitution of "\\1"
				set begin_loc to characterOffset of found object of match_begin
				set nested_begin_loc to begin_loc
				set end_loc to begin_loc
			else
				return "\\end{#SELSTART#???#SELEND#}"
			end if

			-- search for end environment, accounting for nesting
			-- continues until the next begin{env} is after the next end{env}
			repeat
				set match_nested_begin to find "\\\\begin{" & _env & "}" searching in characters (nested_begin_loc + 1) through -1 of _doc
				set match_end to find "\\\\end{" & _env & "}" searching in characters (end_loc + 1) through -1 of _doc

				if found of match_end then
					set end_loc to characterOffset of found object of match_end
				else
					return "\\end{" & _env & "}" & return & "#INSERTION#"
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

		return "\\end{#SELSTART#???#SELEND#}"

	end tell

end run
