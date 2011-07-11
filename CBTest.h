//
//  CBTest.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CourseFile.h"

@class CBQuestion;

@interface CBTest :  CourseFile  
{
}

@property (nonatomic, retain) NSString * passingScore;
@property (nonatomic, retain) NSString * pathToXML;
@property (nonatomic, retain) NSSet* questions;
- (NSMutableDictionary *)encode;
@end


@interface CBTest (CoreDataGeneratedAccessors)
- (void)addQuestionsObject:(CBQuestion *)value;
- (void)removeQuestionsObject:(CBQuestion *)value;
- (void)addQuestions:(NSSet *)value;
- (void)removeQuestions:(NSSet *)value;

@end

