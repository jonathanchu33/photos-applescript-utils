all: filter_unfiled search_album sort_media utils

filter_unfiled: filter_unfiled_media.sh
	chmod 744 filter_unfiled_media.sh

search_album: search_album_membership.applescript utils
	chmod 744 search_album_membership.applescript

sort_media: sort_media.applescript filter_unfiled utils
	chmod 744 sort_media.applescript

utils: utils.applescript
	osacompile -o utils.scpt utils.applescript

clean:
	rm -f *.scpt
