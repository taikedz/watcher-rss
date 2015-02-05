Some notes about how to simplify this utility further

# Channel URL

Channel URL should be written out as the URL of the page we're watching.

# Item extraction

## Stamp extraction

We shuold be able to extract a stamp for each item

## Permalink extraction

We should be able to derive a permalink

# Implementation

Somehow, determine a handle type, an exraction tool, and a sed pattern

	LOCALSTAMP=$(xpath -e //xpath/pattern | sed 's/pat/sub/g' )

The actual bash format is not bad - but introducing handlers instead and documenting them so that a handler script should only need to call the approrpriate handle to pass patterns.

## Types

Each handler type has to be able to return the RSS string itself, and an overall stamp for the entire feed.

* grep
	* this handler is a plain grep pattern that'll extract the correct line
	* as a result, the only other thing to define is a sed pattern to re-write the line
* xpath
	* this handler just gets the first xpath result and processes it through a sed line
	* only one more argument, a sed pattern, is needed thus
* xpaths
	* like the single one, only this has the aditional step of iterating over a set to deterine individual items
	* maybe a general case that the single can call?
	* the sed argument processes each line individually
	* implementation may need to define collections of params instead of globally setting any
* delimited
	* this is a special case to handle streams that are line-based. Think non-HTML, or broken-HTML pages
	* the implementation neeeds to be documented, but see the Tux example

Perhaps make a mechanism to import a named handler - document a $RSS_HANDLERS path where handler scripts get stored?
