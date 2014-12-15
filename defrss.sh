#! /bin/bash

function abortnow() { echo "$@"; exit 1; }

[[ "$EDITOR" ]] || abortnow "\$EDITOR is not set"


FEEDNAME=$(echo $1 | sed -r -e "s/([^a-zA-Z0-9_\.-]+)/_/")

[[ "$FEEDNAME" ]] || abortnow "Specify a feed name"

if [[ ! -f "$FEEDNAME" ]]; then

echo Editing $FEEDNAME;

cat <<EODEMO > $FEEDNAME
#! /bin/bash

# The following definitions are mandatory
RSS_PAGEURL=http://www.example.com
RSS_PAGENAME=Example feed definition
RSS_PAGEID=$(echo $FEEDNAME | sed -r -e "s/([^a-zA-Z0-9_\.-]+)//")

# Process the page
# Note - the main script includes the 'getpage' function to help you download pages easily
function findstamp() {
	NEWSTAMP=\$(getpage "\$RSS_PAGEURL" "-" | grep -E "identifying string" | sed -r -e "s/.+(isolate this).+/\1/")
	#RSS_PERMALINK=define permalink (optional)
	RSS_DESCRIPTION=New change: $NEWSTAMP
	if [[ $NEWSTAMP ]]; then
		NEWSTAMP=$(echo $NEWSTAMP | md5hash)
	else
		# constant stamp - report only once
		NEWSTAMP=FAILED
		# report every failed run
		#NEWSTAMP=FAILED $CURDATE
		RSS_DESCRIPTION="CONTENT DOWNLOAD FAIL"
	fi
}

EODEMO

fi

$EDITOR $FEEDNAME
