//
//  Course.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/13/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import "Course.h"

@implementation Course

@dynamic desc;
@dynamic keywords;
@dynamic title;
@dynamic code;
@dynamic path;

- (void)dealloc
{
	[super dealloc];
}

- (NSString *)filename 
{
    return nil;
}

- (void)setFilename:(NSString *)value 
{
    //
}

- (NSString *)displayName
{
	return [self code];
}

- (NSString *)type 
{
    return nil;
}

- (NSArray *)keysForEncoding
{
	return [[super keysForEncoding] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"title", @"desc", @"code",  nil]];
}

- (NSString *)expandedPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *appSupportFolder = [basePath stringByAppendingPathComponent:@"CourseBuilder"];
	return [appSupportFolder stringByAppendingPathComponent:self.path];
}

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	NSMutableArray *sections = [NSMutableArray array];
	for (id child in [self children]) {
		[sections addObject:[child encode]];
	}
	
    for(NSString *key in attributes)
	{
		NSAttributeDescription *attribute = [attributes objectForKey:key];
		id value = [dict objectForKey:key];
		
		if( (value == nil) || ([value isKindOfClass:[NSNull class]]) )
		{
			if([attribute attributeType] == NSStringAttributeType)
				[dict setObject:@"" forKey:key];
			else
				[dict removeObjectForKey:key];
		}
    }
	
	[dict setValue:sections forKey:@"sections"];
	
    return [dict autorelease];
}

@end