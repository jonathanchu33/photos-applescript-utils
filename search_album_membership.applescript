#!/usr/bin/env osascript

global albumMemberships

-- Main handler
on run
	set albumMemberships to {}
	set utils to load script (POSIX path of ((path to me as text) & "::" & "utils.scpt"))
	
	tell application "Photos"
		activate
		
		-- Verify that media is selected
		set sel to selection
		if sel is {} then
			display dialog "No media items selected."
			return
		end if
		
		-- Select image to search for
		set targetImage to item 1 of sel
		set {imageId, imageName} to {id of targetImage, filename of targetImage}
		display dialog "Searching album membership of image \"" & imageName & "\" (ID " & imageId & ")"
		
		set startTime to current date
		my recursiveAlbumSearch(application "Photos", "", imageId)
		set endTime to current date
		display dialog "\"" & imageName & "\" is a member of " & (count of albumMemberships) & " albums (searched in approx. " & (endTime - startTime) & " sec): " & return & my utils's listToString(albumMemberships, return)
	end tell
end run

-- Handler which recursively searches albums for target item
on recursiveAlbumSearch(parent, albumPath, targetId)
	using terms from application "Photos"
		tell parent
			set targetAlbums to name of (albums whose id of media items contains targetId)
			repeat with a in targetAlbums
				set end of albumMemberships to (albumPath & a)
			end repeat
			repeat with f in folders
				my recursiveAlbumSearch(f, (albumPath & name of f as string) & "/", targetId)
			end repeat
		end tell
	end using terms from
end recursiveAlbumSearch