// 
//  Order.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import "Order.h"

#import "CBAnswer.h"
#import "CBQuestion.h"

@implementation Order 

@dynamic order;
@dynamic cbquestion;
@dynamic cbanswer;

- (void)dealloc
{
	[super dealloc];
}

- (NSNumber *)displayOrder
{
	NSNumber *tmpValue;
	int x;
	[self willAccessValueForKey:@"displayOrder"];
	tmpValue = [self order];
	x = [tmpValue intValue];
	x = x+1;
	tmpValue = [NSNumber numberWithInt:x];
	[self didAccessValueForKey:@"displayOrder"];
	
	return tmpValue;
}

@end
