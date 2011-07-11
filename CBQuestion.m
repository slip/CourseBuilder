// 
//  CBQuestion.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import "CBQuestion.h"

#import "CBAnswer.h"
#import "CBTest.h"
#import "Order.h"

@implementation CBQuestion 

@dynamic keywords;
@dynamic question;
@dynamic feedback;
@dynamic test;
@dynamic order;
@dynamic answers;

- (void)dealloc
{
	[super dealloc];
}

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	NSMutableArray *qAnswers = [NSMutableArray array];
	for (id answer in [self answers]) {
		[qAnswers addObject:[answer encode]];
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
	[dict setValue:qAnswers forKey:@"answers"];
	NSNumber *orderNum = [[self order] order];
	[dict setValue:orderNum forKey:@"order"];
	
    return [dict autorelease];
}

@end
