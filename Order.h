//
//  Order.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 4/1/10.
//  Copyright 2010 normal software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CBAnswer;
@class CBQuestion;

@interface Order :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) CBQuestion * cbquestion;
@property (nonatomic, retain) CBAnswer * cbanswer;
- (NSNumber *)displayOrder;

@end



