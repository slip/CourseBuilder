//
//  NSManagedObject-Utilities.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/31/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import "NSManagedObjectContext-Utilities.h"


@implementation NSManagedObjectContext (Utilities)

- (NSManagedObject *)addManagedObjectOfType:(NSString *)type fromDictionary:(NSDictionary *)dictionaryItem;
{
	NSManagedObject *mo = [NSEntityDescription
						   insertNewObjectForEntityForName:type
						   inManagedObjectContext:self];
	[mo setValuesForKeysWithDictionary:dictionaryItem];
	return mo;
}

- (void)addManagedObjectsOfType:(NSString *)type fromArray:(NSArray *)array;
{
	NSEnumerator *oe = [array objectEnumerator];
	NSDictionary *dictionaryItem = nil;
	
	while(dictionaryItem = [oe nextObject])
		[self addManagedObjectOfType:type fromDictionary:dictionaryItem];
}

- (void)addManagedObjectsOfType:(NSString *)type fromArray:(NSArray *)array relatedToObject:(NSManagedObject *)relation withKey:(NSString *)key;
{
	NSEnumerator *oe = [array objectEnumerator];
	NSDictionary *dictionaryItem = nil;
	
	while(dictionaryItem = [oe nextObject])
	{
		NSManagedObject *mo = [self addManagedObjectOfType:type fromDictionary:dictionaryItem];
		[mo setValue:relation forKey:key];
	}
}

@end
