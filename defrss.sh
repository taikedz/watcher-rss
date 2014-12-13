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
# Note - the main script includes the `getpage` function to help you download pages easily
function findstamp() {
	NEWSTAMP=\$(getpage "\$RSS_PAGEURL" "-" | grep "identifying string" | sed -r -e "s/.+(isolate this).+/\1/")
	#RSS_PERMALINK=define permalink (optional)
	#RSS_DESCRIPTION=define custom description (optional)
}

EODEMO

fi

$EDITOR $FEEDNAME
