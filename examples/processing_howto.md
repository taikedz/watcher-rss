# Processing the TM HowTos section

Perform line by line check:

* Define an entry trigger - either the `<div id="squeeze">` line, or the "File under <ul" line.
* Define an exit trigger - "</ul>" being the most appropriate ; if possible also catch the trailing "</div>"?
* Catch every line and extract with s/^<h5>(<a href.+<\/a>)<\/h5>$/\1/g
	* flush a new RSS entry with each to temp file
* Define new stamp as the hash of the generated entries (catch subsequent edits)
* Write the collected RSS entries out
* Check every 6 hours (smallest divider of both 12 and 24 - just in case)

Question - can this be done as a perl script....??

Maybe...

We woudl need to

1. Cron a master script
2. Master processes and splits the TM page to a custom temp
3. ... this is going to warrant a different approach to implementing genrss.sh

We need to be able to call the RSS generating code from within the handler - have it as a utility

The genrss.sh script itself then takes care of writing a channel with the contents the handler has extracted...
