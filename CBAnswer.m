// 
//  CBAnswer.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import "CBAnswer.h"

#import "CBQuestion.h"
#import "Order.h"

@implementation CBAnswer 

@dynamic isCorrect;
@dynamic answer;
@dynamic order;
@dynamic question;

- (void)dealloc
{
	[super dealloc];
}

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	
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
	NSNumber *orderNum = [[self order] order];
	[dict setValue:orderNum forKey:@"order"];
    return [dict autorelease];
}

@end
