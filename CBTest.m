// 
//  CBTest.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import "CBTest.h"

#import "CBQuestion.h"

@implementation CBTest 

@dynamic passingScore;
@dynamic pathToXML;
@dynamic questions;

- (void) dealloc
{
	[super dealloc];
}

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	NSMutableArray *testQuestions = [NSMutableArray array];
	for (id question in [self questions]) {
		[testQuestions addObject:[question encode]];
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
	
	[dict setValue:testQuestions forKey:@"questions"];
    return [dict autorelease];
}

@end
