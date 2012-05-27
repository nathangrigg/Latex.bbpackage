tell application "BBEdit"

	set _doc to text document 1

	set _cursor to characterOffset of selection

	repeat

		-- Search backwards to previous begin
		-- This is so if your cursor is \begin{equ|ation} it will still work.
		set match_begin to find "\\\\begin{" searching in text 1 of _doc options {backwards:true}
		if not found of match_begin then
			beep
			select insertion point before character _cursor of _doc
			return
		end if
		select insertion point before character (characterOffset of found object of match_begin) of _doc

		-- Extract environment name
		set match_begin to find "\\\\begin{([^}]*)}" searching in text 1 of _doc options {search mode:grep} with selecting match

		if not found of match_begin then
			beep
			select insertion point before character _cursor of _doc
			return
		end if

		set _env to grep substitution of "\\1"

		-- search for end environment, accounting for nesting
		-- continues until the next begin{env} is after the next end{env}
		repeat
			set match_nested_begin to find "\\\\begin{" & _env & "}" searching in text 1 of _doc
			-- "selecting match" advances cursor
			set match_end to find "\\\\end{" & _env & "}" searching in text 1 of _doc with selecting match

			if not found of match_end then
				beep
				select insertion point before character _cursor of _doc
				return
			end if

			if not found of match_nested_begin or (characterOffset of found object of match_nested_begin) > (characterOffset of found object of match_end) then exit repeat
		end repeat

		set _begin to characterOffset of found object of match_begin
		set _end to (characterOffset of found object of match_end) + (length of found object of match_end)


		if _end > _cursor then
			exit repeat
		else
			select insertion point before character _begin of _doc
		end if
	end repeat

	select characters _begin through _end of _doc

end tell

try
	display dialog "Change " & _env & " environment to:" default answer _env with title "Change environment"

on error
	tell application "BBEdit" to select insertion point before character _cursor of _doc
	return
end try

tell application "BBEdit"
	set new_env to text returned of result
	set _diff to (length of new_env) - (length of _env)
	set characters (_begin + 7) through (_begin + 6 + (length of _env)) of _doc to new_env
	set characters (_end - (length of _env) - 1 + _diff) through (_end - 2 + _diff) of _doc to new_env

	select insertion point before character (_cursor + _diff) of _doc
end tell
