//
//  ESTreeNode.h
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

#import <CoreData/CoreData.h>

@interface ESTreeNode : NSManagedObject <NSCoding>
{
}

@property (retain) NSString * displayName;
@property (retain) NSNumber * isSelectable;
@property (retain) NSNumber * isLeaf;
@property (retain) NSNumber * sortIndex;
@property (retain) ESTreeNode * parent;
@property (retain) NSSet* children;

- (NSArray *)descendants;
- (NSArray *)keysForEncoding;

@end

@interface ESTreeNode (CoreDataGeneratedAccessors)
- (void)addChildrenObject:(ESTreeNode *)value;
- (void)removeChildrenObject:(ESTreeNode *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;
@end