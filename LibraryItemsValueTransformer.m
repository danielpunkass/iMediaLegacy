/*
 
 Permission is hereby granted, free of charge, to any person obtaining a 
 copy of this software and associated documentation files (the "Software"), 
 to deal in the Software without restriction, including without limitation 
 the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 and/or sell copies of the Software, and to permit persons to whom the Software 
 is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in 
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 In the case of iMediaBrowse, in addition to the terms noted above, in any 
 application that uses iMediaBrowse, we ask that you give a small attribution to 
 the members of CocoaDev.com who had a part in developing the project. Including, 
 but not limited to, Jason Terhorst, Greg Hulands and Ben Dunton.
 
 Greg doesn't really want acknowledgement he just want bug fixes as he has rewritten
 practically everything but the xml parsing stuff. Please send fixes to 
	<ghulands@framedphotographics.com>
	<ben@scriptsoftware.com>
 
 */


#import "LibraryItemsValueTransformer.h"


@implementation LibraryItemsValueTransformer

int imageDateSort(id i1, id i2, void *context) {
	NSDate *date1;
	NSDate *date2;
	
	if(![[i1 objectForKey:@"DateAsTimerInterval"] isKindOfClass:[NSDate class]])
	{
		NSNumber *d1 = [i1 objectForKey:@"DateAsTimerInterval"];
		NSNumber *d2 = [i2 objectForKey:@"DateAsTimerInterval"];
	
		date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:[d1 doubleValue]];
		date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:[d2 doubleValue]];
	}
	else
	{
		date1 = [i1 objectForKey:@"DateAsTimerInterval"];
		date2 = [i2 objectForKey:@"DateAsTimerInterval"];
	}
	return [date1 compare:date2];
}

+ (Class)transformedValueClass
{
	return [NSString self];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)beforeObject
{
	NSMutableArray *newPhotos = [NSMutableArray array];
	NSArray *playlistRecords = (NSArray*)beforeObject;
	NSEnumerator *playlistRecordsEnum = [playlistRecords objectEnumerator];
	NSDictionary *rec = nil;
	while(rec = [playlistRecordsEnum nextObject])
	{
		[newPhotos addObjectsFromArray:[rec allValues]];
	}
	
	[newPhotos sortUsingFunction:imageDateSort context:nil];
	return newPhotos;
}

@end

