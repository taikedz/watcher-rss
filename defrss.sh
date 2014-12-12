#! /bin/bash

if [[ "x$EDITOR" = "x" ]]; then
	echo "\$EDITOR is not set"
	exit 1
fi


FEEDNAME=$(echo $1 | sed -r -e "s/([^a-zA-Z0-9_\.-]+)/_/")

if [[ "x$FEEDNAME" = "x" ]]; then
	echo Specify a feed name
	exit 2
fi

FEEDFILE=$HOME/.genrss/$FEEDNAME

if [[ ! -f $FEEDFILE ]]; then

cat <<EODEMO > $FEEDFILE
#! /bin/bash

# The following definitions are mandatory
PAGEURL=http://www.example.com
PAGENAME=Example feed definition

# Process the page
function findstamp() {
	cat \$1 | grep "identifying string" | sed -r -e "s/.+(isolate this).+/\1/"
}

EODEMO

fi

$EDITOR $FEEDFILE
