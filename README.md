watcher-rss
===========

Call a script watching for changes, and generate an RSS entry on change

When you're trying to follow a site's updates, you generally hope that it would have an RSS feed. Sometimes it doesn't.

Or maybe you're trying to follow a site that does not provide an RSS for the specific page/subsection you want to follow.

Or maybe you want to be alerted to changes in SOMETHING, SOMEWHERE - directly in your RSS reader?

watcher-rss is a simple bash script designed for that.

Deploy it to your server and call it through your crontab. When its cron job comes up, it loads the releavnt URL profile and checks the target page for changes. If there are, it updates the feed XML appropriately.

Requirements
===

* Somewhere to publish the RSS as an XML file where the RSS consumer can get it
* cron (or equivalent mechanism) to call the script
* bash, wget; GNU cat, sed, grep

Setup
---

1. Download/clone the watcher script genrss.sh and make it executable.
2. Edit genrss.sh and change the path DEFRSSDIR - point this to where you want the feeds to be published
    * for example, DEFRSSDIR=/var/www/html/rss
    * The RSS could then be at http://example.com/rss/example.xml
2. Create handler script (see below) and save it
3. edit your crontab with `crontab -e`
4. Adjust the cron frequency and make the job call the genrss.sh script with examplename `/home/user/bin/genrss.sh exampleName`
5. Save the new crontab

Handler script
===

run `./defrss feedName` to create a new feed file and pre-populate it with some demo handler logic and the required variables.

Here's an example for the FOSDEM event, to monitor its changes - I specifically track its title for changes in the number of events. You could conceivably make your script generate a unique identifier for any change you wanted the script to monitor...

I have my handler file saved as `~/rss/fosdem`

My crontab is set to `0 * * * * /home/me/bin/genrss.sh /home/me/rss/fosdem` to check every hour for updates.

The handler script content is

	#! /bin/bash
	
	# The following definitions are mandatory
	RSS_PAGEURL=https://fosdem.org/2015/schedule/events/
	RSS_PAGENAME="FOSDEM Events"
	RSS_PAGEID=fosdem
	
	# Process the page
	# Note - the main script includes the getpage function to help you download pages easily
	function findstamp() {
	        NEWSTAMP=$(getpage "$RSS_PAGEURL" "-" grep -E "<h1>[0-9]+\\s+Events</h1>" | sed -r -e "s/<h1>.+([0-9]+.+?)<\\h1>/\1/")
		#RSS_PERMALINK=define permalink (optional)
		RSS_DESCRIPTION="Now listing $NEWSTAMP"
	}

The RSS\_PAGEURL and RSS\_PAGENAME are set here. RSS\_PAGENAME will also be the name of the feed path (for example, <http://ducakedhare.co.uk/rss/FOSDEM_Events.xml>).

RSS\_PAGEID determines the id of the RSS feed. It should only have letters and numbers in it, no spaces or other characters.

The findstamp() function must return a string identifying the state of the content - for example the permalink to the content, or something uniquely identifying its state. If this changes between calls, then the watched entity is deemed to have changed and a new RSS entry is created. Conversely, if two calls to findstamp() return the same value, it is deemed that no change has ocurred between the two.

The main genrss.sh uses the value from findstamp() to register the last state of the feed.

More than just page watching
===

Your script could even be conceivably:

	#! /bin/bash
	
	RSS_PAGEURL=mailto:security-team@copmany.com
	RSS_PAGENAME="Server reports"
	RSS_PAGEID=reports
	
	function findstamp() {
		local pulledlogs
		pulledlogs=$(tail /var/log/security)
	        NEWSTAMP=$(echo $pulledlogs | md5hash)
		RSS_PERMALINK=mailto:security-team@company.com?subject=Security+logs+changed
		RSS_DESCRIPTION="<pre>$pulledlogs</pre>"
	}

This would create a new entry in your RSS feed any time the end contents of `/var/log/security` changed. The link would then open an email for you to shoot off a rapid message...

Watch anything!
