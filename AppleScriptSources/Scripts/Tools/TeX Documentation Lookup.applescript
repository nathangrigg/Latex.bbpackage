-- by Nathan Grigg

property package_name : ""

on main()
	-- get texbin from the typeset script
	set typeset_lib_file to path_to_contents() & "Resources/typeset-lib.scpt"
	set typeset_lib to load script POSIX file typeset_lib_file
	display dialog "Which package would you like documentation for?" default answer package_name
	set package_name to text returned of result
	get_tex_docs for package_name from typeset_lib's texbin
end main

on get_tex_docs for package_name from texbin
	try
		set stdout to do shell script "PATH=$PATH:" & quoted form of texbin & " ; texdoc " & (quoted form of package_name)
	on error number 127
		error "Shell command not found: texdoc" number 5033
	end try
	if stdout is not "" then error stdout number 5033
end get_tex_docs

try
	main()
on error eStr number eNum partial result rList from badObj to exptectedType
	if eNum = 5033 then
		display dialog eStr buttons {"OK"} with title "Error" default button 1
	else if eNum = 5088 then
		beep
	else if eNum is not -128 then
		error eStr number eNum partial result rList from badObj to exptectedType
	end if
end try

on path_to_contents()
	--- Returns path to "Contents" folder containing the current script
	local delims, split_string
	set delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "/Contents/"
	set split_string to text items of POSIX path of (path to me)
	set AppleScript's text item delimiters to delims
	if length of split_string = 1 then error "This script must remain inside the Latex BBEdit package because it depends on other scripts in that package." number 5033
	return (item 1 of split_string) & "/Contents/"
end path_to_contents
