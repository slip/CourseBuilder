//
//  NSManagedObjectContext-Utilities.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/31/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSManagedObjectContext (Utilities) 

- (NSManagedObject *)addManagedObjectOfType:(NSString *)type fromDictionary:(NSDictionary *)dictionaryItem;
- (void)addManagedObjectsOfType:(NSString *)type fromArray:(NSArray *)array;
- (void)addManagedObjectsOfType:(NSString *)type fromArray:(NSArray *)array relatedToObject:(NSManagedObject *)relation withKey:(NSString *)key;

@end
