tell application "BBEdit"
	set _doc to document 1
	save _doc
	set _filename to file of _doc
end tell

tell application "TeXShop"
	set _doc to open _filename
	tell _doc to typesetinteractive
end tell