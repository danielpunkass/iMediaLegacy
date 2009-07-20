//
//	Project:	iMediaBrowser <http://karelia.com/imedia/>
//
//	File:		iMBObjectArrayController.h
//
//	Abstract:	This subclass of NSArrayController can search arbitrary properties 
//				or media objects.
//
//	Copyright:	(c) 2005-2008 by Karelia Software et al
//				(c) 2008 by Peter Baumgartner. All rights reserved.
//
//
//	iMedia Browser is licensed under the following terms:
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in all or substantial portions of the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to permit
//	persons to whom the Software is furnished to do so, subject to the following
//	conditions:
//
//		Redistributions of source code must retain the original terms stated here,
//		including this list of conditions, the disclaimer noted below, and the
//		following copyright notice: Copyright (c) 2005-2007 by Karelia Software et al.
//
//		Redistributions in binary form must include, in an end-user-visible manner,
//		e.g., About window, Acknowledgments window, or similar, either a) the original
//		terms stated here, including this list of conditions, the disclaimer noted
//		below, and the aforementioned copyright notice, or b) the aforementioned
//		copyright notice and a link to karelia.com/imedia.
//
//		Neither the name of Karelia Software, nor Sandvox, nor the names of
//		contributors to iMedia Browser may be used to endorse or promote products
//		derived from the Software without prior and express written permission from
//		Karelia Software or individual contributors, as appropriate.
//
//	Disclaimer: THE SOFTWARE IS PROVIDED BY THE COPYRIGHT OWNER AND CONTRIBUTORS
//	"AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//	LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
//	AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//	LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//	CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH, THE
//	SOFTWARE OR THE USE OF, OR OTHER DEALINGS IN, THE SOFTWARE.


//----------------------------------------------------------------------------------------------------------------------


#pragma mark HEADERS

#import "IMBObjectArrayController.h"
#import "IMBCommon.h"


//----------------------------------------------------------------------------------------------------------------------


#pragma mark 

@implementation IMBObjectArrayController

@synthesize delegate = _delegate;
@synthesize searchableProperties = _searchableProperties;
@synthesize searchString = _searchString;


//----------------------------------------------------------------------------------------------------------------------


- (id) init
{
	if (self = [super init])
	{
		_searchableProperties = nil;
		_searchString = nil;
		_delegate = nil;	
	}
	
	return self; 
}


- (void) dealloc
{
	IMBRelease(_searchableProperties);
	IMBRelease(_searchString);
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------------------------


- (IBAction) search:(id)inSender
{
	[self setSearchString:[inSender stringValue]];
}


- (IBAction) resetSearch:(id)inSender
{
	if ([_searchString length])
	{
		[ibSearchField setStringValue:@""];
		[self search:ibSearchField];
	}	
}


//----------------------------------------------------------------------------------------------------------------------


- (NSArray*) arrangeObjects:(NSArray*)inObjects
{
	BOOL hasProxyForObject = _delegate && [_delegate respondsToSelector:@selector(proxyForObject:)];

	// If we have a filterPredicate, then the array is already filtered at this point. All we need 
	// to do is replace the objects with proxies...
	
	if ([self filterPredicate])
	{
		NSArray* arrangedObjects = [super arrangeObjects:inObjects];
		if (!hasProxyForObject) return arrangedObjects;
		NSMutableArray* proxyArray = [NSMutableArray array];
		
		for (id object in arrangedObjects)
		{
			[proxyArray addObject:[_delegate proxyForObject:object]];
		}
		
		return proxyArray;
	}	
	
	
	// Without the predicate, we need to filter the array manually:
	
	else
	{
		BOOL searching = _searchString != nil && 
						 _searchableProperties != nil &&  
						 ![_searchString isEqualToString:@""] &&
						 [_searchableProperties count] > 0;
		
		// Create array of objects that match search string.
		// Also add any newly-created object unconditionally:
		// (a) You'll get an error if a newly-added object isn't added to arrangedObjects.
		// (b) The user will see newly-added objects even if they don't match the search term.
		// (c) The search is not case-sensitive.
		
		NSMutableArray* matchedObjects = [NSMutableArray arrayWithCapacity:[inObjects count]];
		NSString* lowerCaseSearchString = [_searchString lowercaseString];
		id object,proxy;	
		
		for (object in inObjects)
		{
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			proxy = hasProxyForObject ? [_delegate proxyForObject:object] : object;
			
			// If the object has just been created, add it unconditionally...
			
			if (object == _newObject)
			{
				[matchedObjects addObject:proxy];
				_newObject = nil;
			}
			
			// Search all properties in the array. Please note that we need to check for the existance 
			// of a property (value!=nil) BEFORE checking rangeOfString: or a nil value will provide 
			// us with a positive match. This would yield way to many false results...
			
			/*else*/ if (searching)
			{
				NSString* value;
				
				for (NSString* key in _searchableProperties)
				{
					value = [[object valueForKeyPath:key] lowercaseString];
					
					if (value!=nil && [value rangeOfString:lowerCaseSearchString].location!=NSNotFound)
					{
						[matchedObjects addObject:proxy];
						break;
					}
				}
			}
			else
			{
				[matchedObjects addObject:proxy];
			}
				
			[pool release];
		}
		
		return [super arrangeObjects:matchedObjects];
	}
}


//----------------------------------------------------------------------------------------------------------------------


// Set default values, and keep reference to new object -- see arrangeObjects:

- (id) newObject
{
    _newObject = [super newObject];
	
//	for (NSString* key in _searchableProperties)
//	{
//		[_newObject setValue:key forKey:key];
//	}

    return _newObject;
}


//----------------------------------------------------------------------------------------------------------------------


@end