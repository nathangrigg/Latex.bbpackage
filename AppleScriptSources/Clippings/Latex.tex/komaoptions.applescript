-- by Nathan Grigg
on run
	set _list to {"abstract=true				Inserts the text “Abstract” before the abstract", "abstract=false", "appendixprefix=true			Prefix appendix headings with “Appendix”", "appendixprefix=false", "bibliography=totoc			Entry for bibliography in table of contents", "bibliography=totocnumbered	Numbered entry for bibliography in toc", "captions=oneline				Centers one-line captions", "captions=nooneline			No special caption treatment", "captions=tableheading		Captions are placed above tables", "captions=tablesignature		Captions are placed below tables", "chapterprefix=true			Prefix chapter headings with “Chapter”", "chapterprefix=false", "cleardoublepage=current		Standard headings on blank pages", "cleardoublepage=plain		Page number only on blank pages", "cleardoublepage=empty		Nothing printed on blank pages", "footsepline=true				Leave blank line before footer", "footsepline=false", "headings=small				Small chapter and section headings", "headings=big", "headings=normal", "headsepline=true				Leave blank line after header", "headsepline=false", "index=totoc					Entry for index in table of contents", "listof=totoc					Entry for list of figures in table of contents", "listof=flat					No indents for lists of figures", "listof=graduated				Indents for lists of figures", "numbers=enddot				Include a dot after chapter numbers", "numbers=noenddot", "open=right					Opens new chapters on right pages only", "open=any", "paper=letterpaper			Letter sized paper", "paper=letterpaper,landscape	Landscape letter sized paper", "parindent					Indent paragraphs, no skip between pars", "parskip=full					Full skip between pars, 1em free space", "parskip=full*					Full skip between pars, quarter line free", "parskip=full+				Full skip between pars, third line free", "parskip=full-				Full skip between pars, no free space", "parskip=half					Half skip between pars, 1em free space", "parskip=half*				Half skip between pars, quarter line free", "parskip=half+				Half skip between pars, third line free", "parskip=half-				Half skip between pars, no free space", "titlepage=true				Separate page for title", "titlepage=false", "toc=flat						No indentation in the table of contents", "toc=graduated				Varied indents in the table of contents"}

	-- display dialog
   	set _response to choose from list _list with prompt "Select one or more KOMA Options." with multiple selections allowed
    if _response is false then return ""


	-- extract command
	set AppleScript's text item delimiters to "	"
	set _wordlist to {}
	repeat with _item in _response
		set _word to text item 1 of _item
		set _wordlist to _wordlist & _word
	end repeat

	-- make comma-separated list
	set AppleScript's text item delimiters to ","

	return (_wordlist as string)
end run
