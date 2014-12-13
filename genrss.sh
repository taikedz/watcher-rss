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

# Location to create the RSS feed file
# Should be somewhere you can access over HTTP
#   or where the intended feed consumer can reach it
RSS_DIR="/var/www/rss"

# Where the stamps are kept
RSS_STAMPS="$HOME/.rss-stamps"

# Utility to help in getting pages
# Call this from your own script to download a page
# getpage URL OUTDOC
# Specify the URL to download from; OUTDOC can either be a file, or "-" to write to stdout
#   `getpage "http://www.example.com" "-"`
function getpage() {
	# getpage pageurl localfile
        wget -q "$1" --header='User-Agent: Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0' --output-document="$2"
}

# ==================================
# Check that we can read the stamp file

touch "$RSS_STAMPS"
if [[ $? != 0 ]]; then
	echo Failed to access stamps database $RSS_STAMPS
fi

# Check existence of handler script
HANDLER=$1
if [[ ! -f "$HANDLER" ]]; then
	echo Could not find handler script "$1"
fi


# The handler script is loaded in the current context
# It must define:
#   findstamp() - identify in /tmp/genrss-tempfile the string
#        identifying new content, and return md5 of that identifying string
#   RSS_PAGENAME - the name of the rss feed file
#   RSS_PAGEURL - the URL of the page
#   RSS_PAGEID - the stamp ID under which to register stamp
#
# Optionally define these in handler script
#   RSS_PERMALINK - permalink - optional
#   RSS_DESCRIPTION - extract a portion of the page - optional
source "$HANDLER"

function rssabort() { echo "$@" ; exit 1; }

[[ "$RSS_PAGENAME" && "$RSS_PAGEURL" && "$RSS_PAGEID" ]] || rssabort "The required parameters were not provided by the handler script."

CURDATE=$(date)
LASTSTAMP=$(cat "$RSS_STAMPS" | grep "$RSS_PAGEID:" | sed -r -e "s/$RSS_PAGEID:(.+)/\1/")

findstamp
NEWSTAMP=$(echo $NEWSTAMP | head -n 1) # ensure it sits only on one line
if [[ $? != 0 ]]; then rssabort "Handler did not define findstamp()"; fi

# If these are not defined after the call to `findstamp` then define them.
[[ "$RSS_PERMALINK" ]] || RSS_PERMALINK="$RSS_PAGEURL"
[[ "$RSS_DESCRIPTION" ]] || RSS_DESCRIPTION="<a href=\"$RSS_PAGEURL\">New content! $RSS_PAGENAME / $NEWSTAMP</a>"

if [[ $LASTSTAMP != $NEWSTAMP ]]; then
        # save the new identifier
        sed -i -r -e "s/$RSS_PAGEID\:.+\$/$RSS_PAGEID:$NEWSTAMP/" "$RSS_STAMPS"
	RSSNAME=$(echo "$RSS_PAGENAME" | sed -r -e s/[^a-zA-Z0-9]+/_/)
        cat <<EOFEED > "$RSS_DIR/$RSSNAME.xml"
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
<title>Automated $RSS_PAGENAME RSS feed</title>
<description>This is an automated feed for $RSS_PAGENAME.<br />This is not an official feed and may not be up to date.</description>
<generator>https://github.com/taikedz/watcher-rss/</generator>
<link>$RSS_PAGEURL</link>
<lastBuildDate>$CURDATE</lastBuildDate>

<item>
<title>$RSS_PAGENAME retrieved $CURDATE</title>
<description>$RSS_DESCRIPTION</description>
<link>$RSS_PERMALINK</link>
<pubdate>$CURDATE</pubdate>
<guid>$NEWSTAMP $CURDATE</guid>
</item>

</channel>
</rss>
EOFEED
fi

# first time we've parsed this page/profile
[[ "$LASTSTAMP" ]] || echo "$RSS_PAGEID:$NEWSTAMP" >> "$RSS_STAMPS"
