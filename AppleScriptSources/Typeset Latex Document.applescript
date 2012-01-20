tell application "BBEdit"
	set _doc to document 1
	save _doc
	if source language of _doc is not "TeX" then
		set _result to display dialog "You are attempting to typeset a non-tex file." buttons {"Quit", "Continue"} default button "Quit"
		if button returned of _result is "Quit" then
			return
		end if
	end if
	set _filename to file of _doc
end tell

tell application "TeXShop"
	set _doc to open _filename
	tell _doc to typesetinteractive
end tell
