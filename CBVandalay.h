//
//  CBImporter.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 9/3/09.
//  Copyright 2009 normal software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Course.h"
#import "Section.h"
#import "CourseFile.h"
#import "CBTest.h"
#import "CBQuestion.h"
#import "CBAnswer.h"
#import "Order.h"
#import "CourseFileManager.h"
#import "ESTreeController.h"
#import "NSManagedObjectContext-Utilities.h"

@interface CBVandalay : NSObject{
	NSFileManager *fileManager;
	NSString *origin;
	NSString *appSupportFolder;
	NSString *destination;
	Course *course;
	NSManagedObjectContext *vandalayMoc;
	IBOutlet ESTreeController *treeController;
}

- (id)initWithCourse:(Course *)courseFromApp andDestination:(NSString *)pathToDestination;
- (id)initWithArchive:(NSString *)pathToArchive andContext:(NSManagedObjectContext *)moc;

- (NSFileManager *)fileManager;
- (NSString *)appSupportFolder;

- (BOOL)createCourseObjectPlist;
- (BOOL)exportCourse;
- (BOOL)copyToDestination;
- (BOOL)convertCourse;
- (BOOL)updatePaths;
- (void)dealloc;

- (BOOL)importCourse:(NSString *)pathToCourse;

@end