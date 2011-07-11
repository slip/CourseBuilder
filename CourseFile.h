//
//  CourseFile.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/13/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ESLeafNode.h"


@interface CourseFile : ESLeafNode {

}
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *type;

- (NSString *)expandedPath;
- (NSString *)pathToFla;
- (NSString *)pathToSwf;

- (BOOL)hasFla;
- (BOOL)hasSwf;

@end

@interface CourseFile (CoreDataGeneratedAccessors)
@end