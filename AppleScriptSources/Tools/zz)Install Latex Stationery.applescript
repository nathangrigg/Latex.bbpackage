-- get the path to package contents
try
	set _path to term(POSIX path of (path to me), "/Contents/")
on error
	error "This script must remain inside the Latex BBEdit package because it needs to access other files from the package."
end try

set _stationery_folder to POSIX file (_path & "Stationery")

tell application "Finder"
	set _stationery to every file of folder _stationery_folder
	repeat with s in _stationery
		tell s to set stationery to true
	end repeat
end tell

display dialog "After restarting BBEdit, you can use the \"New with Stationery\" command from the File menu to access the Latex Stationery." buttons {"OK"} default button "OK"

on term(str, terminator)
	set _l to length of terminator
	set _n to (offset of terminator in str)
	if _n is 0 then error "Not found in string"
	return text 1 thru (_l + _n - 1) of str
end term
