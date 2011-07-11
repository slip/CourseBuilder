//
//  Course.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/13/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ESGroupNode.h"
@class Section;
@class CourseFile;

@interface Course : ESGroupNode {

}

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * path;

- (NSString *)displayName;

- (NSString *)filename;
- (void)setFilename:(NSString *)value;
- (NSMutableDictionary *)encode;
- (NSString *)expandedPath;

@end
