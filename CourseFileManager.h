//
//  CourseFileManager.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/6/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Course.h"

@interface CourseFileManager : NSObject {
	NSFileManager *fileManager;
	NSString *appSupportFolder;
	Course *course;
	NSString *courseCode;
	NSString *courseType;
	NSString *coursePath;
}
- (id)initWithCourse:(Course *)aCourse;
- (id)initWithCourseCode:(NSString *)code 
				 andType:(NSString *)type;

- (NSFileManager *)fileManager;
- (NSString *)appSupportFolder;

- (void)createCourseDirectory;
- (void)deleteCourseDirectory;

- (void)overwriteCourseWithGatedCourse;

- (void)copyLmsFiles;

- (void)copyFileWithPath:(NSString *)path;

- (BOOL)buildCourseToDesktop;

@end