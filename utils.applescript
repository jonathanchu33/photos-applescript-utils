-- Handler which converts list to string
on listToString(lst, delim)
	set {origTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, delim}
	set str to lst as string
	set AppleScript's text item delimiters to origTID
	return str
end listToString