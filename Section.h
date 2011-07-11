//
//  Section.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/20/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ESGroupNode.h"


@interface Section : ESGroupNode {

}

- (NSString *)desc;
- (void)setDesc:(NSString *)value;
- (NSString *)title;
- (void)setTitle:(NSString *)value;

@end
