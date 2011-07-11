//
//  CBQuestion.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CBAnswer;
@class CBTest;
@class Order;

@interface CBQuestion :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * feedback;
@property (nonatomic, retain) CBTest * test;
@property (nonatomic, retain) Order * order;
@property (nonatomic, retain) NSSet* answers;
- (NSMutableDictionary *)encode;

@end


@interface CBQuestion (CoreDataGeneratedAccessors)
- (void)addAnswersObject:(CBAnswer *)value;
- (void)removeAnswersObject:(CBAnswer *)value;
- (void)addAnswers:(NSSet *)value;
- (void)removeAnswers:(NSSet *)value;

@end

