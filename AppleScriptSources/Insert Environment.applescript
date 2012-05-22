try
	set dialogResult to display dialog "Which environment?" default answer "" with title "Insert Latex environment" buttons {"Cancel", "Insert"} default button "Insert" cancel button "Cancel"
on error
	return
end try

set environmentName to text returned of dialogResult

tell application "BBEdit"

	set cursorLocation to selection
	set selectedText to cursorLocation as text
	set text of cursorLocation to "\\begin{" & environmentName & "}" & return & selectedText & return & "\\end{" & environmentName & "}"

	set _insertion_length to 9 + (length of environmentName)
	set _offset to characterOffset of cursorLocation
	select insertion point before character (_offset + _insertion_length + (length of selectedText)) of document 1


end tell
