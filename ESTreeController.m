//
//  ESTreeController.m
//  SortedTree
//
//  Created by Jonathan Dann on 14/05/2008.
//
// Copyright (c) 2008 Jonathan Dann
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "Sorted Tree" by Jonathan Dann" will do.

#import "ESTreeController.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"

@interface ESTreeController (Private)
- (void)updateSortOrderOfModelObjects;
@end

@implementation ESTreeController (Private)
- (void)updateSortOrderOfModelObjects;
{
	for (NSTreeNode *node in [self flattenedNodes])
		[[node representedObject] setValue:[NSNumber numberWithInt:[[node indexPath] lastIndex]] forKey:@"sortIndex"];
}
@end


@implementation ESTreeController
- (void)insertObject:(id)object atArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{
	[super insertObject:object atArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)insertObjects:(NSArray *)objects atArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[super insertObjects:objects atArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath;
{
	[super removeObjectAtArrangedObjectIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}

- (void)removeObjectsAtArrangedObjectIndexPaths:(NSArray *)indexPaths;
{
	[super removeObjectsAtArrangedObjectIndexPaths:indexPaths];
	[self updateSortOrderOfModelObjects];
}

- (void)moveNode:(NSTreeNode *)node toIndexPath:(NSIndexPath *)indexPath;
{
	[super moveNode:node toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];	
}

- (void)moveNodes:(NSArray *)nodes toIndexPath:(NSIndexPath *)indexPath;
{
	[super moveNodes:nodes toIndexPath:indexPath];
	[self updateSortOrderOfModelObjects];
}
@end
