#!/usr/bin/env osascript

global myAlbums
global filedMedia
global filedMediaIds

-- Main handler
on run
	set myAlbums to {}
	set filedMedia to {}
	set filedMediaIds to {}
	set utils to load script (POSIX path of ((path to me as text) & "::" & "utils.scpt"))
	activate application "Photos"
	
	-- 1. Collect all media items which are filed in albums
	set startTime to current date
	recursiveAlbumCollection(application "Photos", "")
	set collectedFiledTime to current date
	tell application "Photos" to display dialog "Found " & (count of filedMedia) & " media items filed in the " & (count of myAlbums) & " albums below in approx. " & (collectedFiledTime - startTime) & " seconds: " & return & my utils's listToString(myAlbums, return)
	set continueTime to current date
	
	-- 2. Collect IDs of all media items in Photo library, convert to convenient format
	set filedMediaIdsString to utils's listToString(filedMediaIds, " ")
	tell application "Photos" to set mediaItemIdsList to id of media items
	set mediaItemIdsString to utils's listToString(mediaItemIdsList, " ")
	
	-- 3. Filter for list of indices corresponding to unfiled media in mediaItemIdsList using faster *nix tools
	set unfiledMediaIndicesString to do shell script (POSIX path of ((path to me as text) & "::" & "filter_unfiled_media.sh")) & " \"" & mediaItemIdsString & "\" \"" & filedMediaIdsString & "\""
	set unfiledMediaIndicesList to words of unfiledMediaIndicesString
	
	-- 4. Collect all media items which are not filed in any albums
	set unfiledMedia to getUnfiledMedia(unfiledMediaIndicesList)
	set collectedUnfiledTime to current date
	tell application "Photos" to display dialog "Found " & (count of unfiledMedia) & " (remaining) unfiled media items in approx. " & (collectedUnfiledTime - continueTime) & " seconds."
	
	-- 5. Create new albums containing filed and unfiled media items
	createAlbum("Filed Media", filedMedia)
	createAlbum("Unfiled Media", unfiledMedia)
end run

-- Handler which recursively finds media filed in albums
on recursiveAlbumCollection(parent, albumPath)
	using terms from application "Photos"
		tell parent
			repeat with a in albums
				if "Unfiled Media" is not in name of a and "Filed Media" is not in name of a then
					set end of myAlbums to (albumPath & name of a as string)
					set filedMedia to (filedMedia & media items of a)
					set filedMediaIds to (filedMediaIds & id of media items of a)
				end if
			end repeat
			repeat with f in folders
				my recursiveAlbumCollection(f, (albumPath & name of f as string) & "/")
			end repeat
		end tell
	end using terms from
end recursiveAlbumCollection

-- Handler which collects unfiled media items given their *indices* (not IDs)
on getUnfiledMedia(unfiledMediaIndexList)
	tell application "Photos"
		set mediaItemList to media items
		set unfiledMedia to {}
		repeat with i in unfiledMediaIndexList
			set end of unfiledMedia to item i of mediaItemList
		end repeat
		return unfiledMedia
	end tell
end getUnfiledMedia

-- Handler which collects unfiled media without leaving AppleScript. Much slower; unused in main run handler. If used, would replace steps 2-4.
on getUnfiledMediaDirect()
	set startTime to current date
	set filteredMedia to {}
	tell application "Photos"
		repeat with m in media items
			if id of m is not in filedMediaIds then
				set end of filteredMedia to m
			end if
		end repeat
		set endTime to current date
		display dialog "Found " & (count of filteredMedia) & " (remaining) unfiled media items in approx. " & (endTime - startTime) & " seconds."
		return filteredMedia
	end tell
end getUnfiledMediaDirect

-- Handler which creates new albums
on createAlbum(albumName, mediaList)
	set startTime to current date
	tell application "Photos"
		set albumName to albumName & " - " & short date string of (current date) & ", " & time string of (current date)
		set newAlbum to make new album named albumName
		add mediaList to newAlbum
		set endTime to current date
		display dialog "Album created in approx. " & (endTime - startTime) & " seconds: " & albumName
	end tell
end createAlbum