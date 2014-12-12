watcher-rss
===========

Watch a site and generate an RSS entry on change

When you're trying to follow a site's updates, you generally hope that it would have an RSS feed. Sometimes it doesn't.

Or maybe you're trying to follow a site that does not provide an RSS for the specific page/subsection you want to follow.

Or maybe you want to be alerted to changes in a page when the page itself changes - but in your RSS reader?

watcher-rss is a simple bash script designed for that.

Deploy it to your server and call it through your crontab. When its cron job comes up, it loads the releavnt URL profile and checks the target page for changes. If there are, it updates the feed XML appropriately.

Requirements
===

* Web server - to publish the RSS file
* cron (or equivalent mechanism) to call the script
* Server with bash and general POSIX utils. Originally written on Linux. May work on OS X. May work on Windows with cygwin. Not tested.

Setup
---

1. Download/clone the watcher script genrss.sh and make it executable.
2. Edit genrss.sh and change the path DEFRSSDIR - point this to where you want the feeds to be published
    * for example, DEFRSSDIR=/var/www/html/rss
    * The RSS could then be at http://example.com/rss/example.xml
2. Run it once to create the necessary directories
3. Create handler profile (see below) and save it to ~/.genrss/exampleName
4. edit your crontab with `crontab -e`
5. Adjust the cron frequency and make the job call the genrss.sh script with examplename `/home/user/bin/genrss.sh exampleName`
6. Save the new crontab

Profile file
===

run `./defrss feedName` to create a new feed file in ~/.genrss/ and pre-populate it with a basic handler.

Here's an example for Sinfest, a webcomic I follow but that has no RSS.

I have this file saved as `~/.genrss/sinfest`

My crontab is set to `0 6 * * * /home/me/bin/genrss.sh sinfest` to check every morning at 06:00 for a new comic.

The profile file content is

	PAGEURL=http://sinfest.net
	PAGENAME=Sinfest!
	
	# this function receives as argument the page specified
	function findstamp() {
	   cat $1 | grep -E "<img src=\"btphp/comics/.+?.gif\" alt=\".+?\">" | sed -r -e "s/^.+alt=\"(.+?)\">.+\$/\1/"
	}

The PAGEURL and PAGENAME are set here. PAGENAME will also be the name of the feed path (for example, http://ducakedhare.co.uk/rss/Sinfest_.xml)

TODO
===

Move page download logic to profile script?

Demonstrate use of custom tools/external scripts in profile script
