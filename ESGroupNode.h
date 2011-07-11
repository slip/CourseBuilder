//
//  ESGroupNode.h
//  SortedTree
//
//  Created by Jonathan on 12/05/2008.
//  Copyright 2008 EspressoSoft. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ESTreeNode.h"


@interface ESGroupNode : ESTreeNode  
{
}

@property (retain) NSNumber * canExpand;
@property (retain) NSNumber * canCollapse;
@property (retain) NSNumber * isExpanded;
@property (retain) NSNumber * isSpecialGroup;

@end


