//
//  CBAnswer.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CBQuestion;
@class Order;

@interface CBAnswer :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * isCorrect;
@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) Order * order;
@property (nonatomic, retain) CBQuestion * question;
- (NSMutableDictionary *)encode;

@end



