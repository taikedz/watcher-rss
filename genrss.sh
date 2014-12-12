#! /bin/bash

# Copyright 2014 Tai Kedzierski
# https://github.com/taikedz/watcher-rss
#
# This code is licensed under the GNU Affero General Public License v3.0
# https://www.gnu.org/licenses/agpl-3.0.html

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# ====================================================

# To use this script
# `crontab -e`
# then add an entry at the desired frequency
# `genrss pageid`
#
# you need to define a bash file at $HOME/.genrss/$PAGEID
# it defines functions and variables for parsing the page

GENRSSRC="$HOME/.genrss"
DBFILE=rss-db
DEFRSSDIR="./"

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

if [[ "x$1" = "x" ]]; then
	exit
elif [[ ! -f "$GENRSSRC/$1" ]]; then
	echo "$1" is not a valid configuration.
	exit 1
fi

# these functions can be overidden in definition file
function getpermalink() {
echo "$PAGEURL"
}
function getdescription() {
echo "<a href=\"$PAGEURL\">$PAGENAME</a>"
}

function getpage() {
	# getpage pageurl localfile
        wget -q "$1" --header='User-Agent: Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0' --output-document="$2"
}

PAGEID=$1
PAGEPREFS="$GENRSSRC/$PAGEID"

# this is where we load the configs for the specified page
# Defining:
#   findstamp() - identify in /tmp/genrss-tempfile the string
#        identifying new content, and return md5 of that identifying string
#   $PAGENAME - the name of the rss feed file
#   $PAGEURL - the URL of the page
#
#   getpermalink() - permalink - optional
#   getdescription() - extract a portion of the page - optional
source "$PAGEPREFS"

TMPFILE=$(mktemp)
getpage "$PAGEURL" $TMPFILE

CURDATE=$(date)
LASTSTAMP=$(cat "$GENRSSRC/$DBFILE" | grep "$PAGEID:" | sed -r -e "s/$PAGEID:(.+)\$/\1/")

NEWSTAMP=$(findstamp $TMPFILE | head -n 1) # ensure it sits only on one line
GENLINK=$(getpermalink)
PAGEDESCRIPTION=$(getdescription)

if [[ $LASTSTAMP != $NEWSTAMP ]]; then
        # save the new identifier
        sed -i -r -e "s/$PAGEID:.+$/$PAGEID:$NEWSTAMP/" "$GENRSSRC/$DBFILE"
	RSSNAME=$(echo $PAGENAME | sed -r -e s/[^a-zA-Z0-9]+/_/)
        cat <<EOFEED > "$DEFRSSDIR/$RSSNAME.xml"
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
<title>Automated $PAGENAME RSS feed</title>
<description>This is an automated feed for $PAGENAME hosted at $PAGEURL.<br />Depending on the server configuration, this feed may not be up to date.</description>
<link>https://github.com/taikedz/</link>
<lastBuildDate>$CURDATE</lastBuildDate>

<item>
<title>$PAGENAME retrieved $CURDATE</title>
<description>$PAGEDESCRIPTION</description>
<link>$GENLINK</link>
<pubdate>$CURDATE</pubdate>
<guid>$NEWSTAMP $CURDATE</guid>
</item>

</channel>
</rss>
EOFEED
fi

# first time we've parsed this page/profile
if [[ "x$LASTSTAMP" = "x" ]]; then
        echo "$PAGEID:$NEWSTAMP" > "$GENRSSRC/$DBFILE"
fi

# cleanup temp
rm $TMPFILE
