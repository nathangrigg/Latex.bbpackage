-- by Nathan Grigg

on run
	try
		set dialogResult to display dialog "Which environment?" default answer "" with title "New Latex environment" buttons {"Cancel", "Insert"} default button "Insert" cancel button "Cancel"
	on error
		return
	end try

	set environmentName to text returned of dialogResult

	return "\\begin{" & environmentName & "}" & return & tab & "#SELECTIONORINSERTION#" & return & "\\end{" & environmentName & "}" & return
end run
