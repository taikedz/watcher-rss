#! /bin/bash

# To use this script
# `crontab -e`
# then add an entry at the desired frequency
# `genrss pageid`
#
# you need to define a bash file at $HOME/.genrss/$PAGEID
# it defines functions and variables for parsing the page

GENRSSRC="$HOME/.genrss"
DBFILE=rss-db
DEFRSSDIR="$GENRSSRC/feeds"

function dolog() {
        # echo $@
        :
}

function trymkdir() {
        mkdir -p $1
        if [[ $? != 0 ]]; then
                echo "Failed to create $1"
                exit 1
        fi
}

if [[ ! -d $GENRSSRC ]]; then
        trymkdir $GENRSSRC
        trymkdir $DEFRSSDIR
        touch "$GENRSSRC/$DBFILE"
fi

dolog Passed Dir creationg

# these functions can be overidden in definition file
function getpermalink() {
echo "$PAGEURL"
}
function getdescription() {
echo "<a href=\"$PAGEURL\">$PAGENAME</a>"
}

function getpage() {
# getpage pageurl localfile
        dolog URL -- $1
        dolog TMP -- $2
        wget -q "$1" --header='User-Agent: Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0' --output-document="$2"
}

PAGEID=$1
PAGEPREFS="$GENRSSRC/$PAGEID"

# this is where we store the configs for the page
# Defining:
#   findstamp() - identify in /tmp/genrss-tempfile the string
#        identifying new content, and return that identifying string
#   $PAGENAME - the name of the rss feed file
#   $PAGEURL - the URL of the page
#
#   getpermalink() - permalink - optional
#   getdescription() - extract a portion of the page - optional
source "$PAGEPREFS"
dolog source loaded $PAGEID - $PAGEURL - $PAGENAME - $(findstamp)

dolog getting page...
getpage "$PAGEURL" /tmp/genrss-tempfile
dolog Got page.

CURDATE=$(date)
LASTSTAMP=$(cat "$GENRSSRC/$DBFILE" | grep "$PAGEID:" | sed -r -e "s/$PAGEID:(.+)\$/\1/")

NEWSTAMP=$(findstamp)
GENLINK=$(getpermalink)
PAGEDESCRIPTION=$(getdescription)

if [[ $LASTSTAMP != $NEWSTAMP ]]; then
        # save the new identifier
        sed -i -r -e "s/$PAGEID:.+$/$PAGEID:$NEWSTAMP/" "$GENRSSRC/$DBFILE"
        cat <<EOFEED > "$DEFRSSDIR/$PAGENAME.xml"
<?xml version="1.0! encoding="UTF-8" ?>
<rss version="2.0">
<channel>
<title>Automated $PAGENAME RSS feed</title>
<description>This is an automated feed for $PAGENAME hosted at $PAGEURL.<br />Depending on the server configuration, this feed may not be up to date.</description>
<link>https://github.com/taikedz/</link>

<item>
<title>$PAGENAME retrieved $CURDATE</title>
<description>$PAGEDESCRIPTION</description>
<link>$GENLINK</link>
<pubdate>$CURDATE</pudate>
</item>

</channel>
</rss>
EOFEED
else
        dolog No change.
fi

# first time we've parsed this comic
if [[ "x$LASTSTAMP" = "x" ]]; then
        echo "$PAGEID:$NEWSTAMP" > "$GENRSSRC/$DBFILE"
fi
