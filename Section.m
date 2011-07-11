//
//  Section.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/20/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import "Section.h"



@implementation Section

- (void)dealloc
{
	[super dealloc];
}

- (NSString *)desc 
{
	return nil;
}

- (void)setDesc:(NSString *)value 
{
	//
}

- (NSString *)filename 
{
	return nil;
}

- (void)setFilename:(NSString *)value 
{
	//
}

- (NSString *)keywords 
{
	return nil;
}

- (void)setKeywords:(NSString *)value 
{
	//
}

- (NSString *)code 
{
	return nil;
}

- (NSString *)type 
{
    return nil;
}

- (void)setCode:(NSString *)value 
{
	//
}

- (NSString *)title 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"title"];
    tmpValue = [self primitiveValueForKey:@"title"];
    [self didAccessValueForKey:@"title"];
    
    return tmpValue;
}

- (void)setTitle:(NSString *)value 
{
    [self willChangeValueForKey:@"title"];
    [self setPrimitiveValue:value forKey:@"title"];
    [self didChangeValueForKey:@"title"];
}

- (NSString *)displayName
{
	return [self title];
}

- (NSArray *)keysForEncoding
{
	return [[super keysForEncoding] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"title", nil]];
}

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	NSMutableArray *courseFiles = [NSMutableArray array];
	for (id child in [self children]) {
		[courseFiles addObject:[child encode]];
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
	
	[dict setValue:courseFiles forKey:@"coursefiles"];
	
    return [dict autorelease];
}

@end
