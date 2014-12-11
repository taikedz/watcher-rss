watcher-rss
===========

Watch a site and generate an RSS entry on change

When you're trying to follow a site's updates, you generally hope that they'd have an RSS feed.

Or maybe you're trying to follow a site that does not provide an RSS for the specific page you want to follow.

Or maybe you want to be alerted to changes in a page when the page itself changes - but in your RSS reader?

watcher-rss is a simple script designed for that.

Deploy it to your server and add it to your crontab. When its cron job comes up, it loads the releavnt URL profile and checks the target page for changes. If there are, it updates the feed XML appropriately.

Requirements
===

* Web server
* cron (or equivalent mechanism to call the script
* *nix server or equivalent

Setup
---

1. Save the watcher script and make it executable.
2. Edit genrss.sh and change the path DEFRSSDIR - point this to where you want the feeds to be published
    * for example, DEFRSSDIR=/var/www/html/rss
    * The RSS will be at http://example.com/rss/example.xml
2. Run it once to create the necessary directories
3. Create handler profile (see below) and save it to ~/.genrss/exampleName
4. edit your crontab with `crontab -e`
5. Adjust the cron frequency and make the job call the genrss.sh script with examplename `/home/user/bin/genrss.sh exampleName`
6. Save the new crontab

Profile file
===

Here's an example for Sinfest, a webcomic I follow but that has no RSS.

I have this file saved as `~/.genrss/sinfest`

My crontab is set to `7 0 * * * /home/me/bin/genrss.sh sinfest` to check every morning at 7:00 for a new comic.

The profile file content is

	PAGEURL=http://sinfest.net
	PAGENAME=Sinfest!
	
	function findstamp() {
	   cat /tmp/genrss-tempfile | grep -E "<img src=\"btphp/comics/.+?.gif\" alt=\".+?\">" | sed -r -e "s/^.+alt=\"(.+?)\">.+\$/\1/"
	}

The PAGEURL and PAGENAME are set here. PAGENAME will also be the name of the feed path (for example, http://example.com/rss/Sinfest!.xml)
