//
//  CourseFile.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/13/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import "CourseFile.h"

@implementation CourseFile

@dynamic desc;
@dynamic filename;
@dynamic keywords;
@dynamic path;
@dynamic title;
@dynamic type;

- (void)dealloc
{
	[super dealloc];
}

- (NSString *)filename 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"filename"];
    tmpValue = [self primitiveValueForKey:@"filename"];
    [self didAccessValueForKey:@"filename"];
    
    return tmpValue;
}

- (void)setFilename:(NSString *)value 
{	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *newPath = [[[self path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:value];
	NSString *newExpandedPath = [[[self expandedPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:value];
	
	// check to see if a file exists at the new path
	if ([fm fileExistsAtPath:newExpandedPath]) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"That file already exists" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"A file already exists with the name %@. To replace it with this file, first delete the original.", value];
		[alert runModal];
		return;
	}
	
    [self willChangeValueForKey:@"filename"];
    [self setPrimitiveValue:value forKey:@"filename"];

	// change the path
	NSLog(@"about to change the path to: %@", newPath);
	[self setPath:newPath];

    [self didChangeValueForKey:@"filename"];	
}

- (NSString *)path 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"path"];
    tmpValue = [self primitiveValueForKey:@"path"];
    [self didAccessValueForKey:@"path"];
    
    return tmpValue;
}

- (void)setPath:(NSString *)value 
{
	// change the filenames within the filesystem
	NSString *newFileName = [value lastPathComponent];

	NSString *originalFullPath = [self expandedPath];
	NSString *newFullPath = [[[self expandedPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];
	
	NSFileManager *fm = [NSFileManager defaultManager];
		
	// change the fla
	if ([self hasFla]) {
		[fm moveItemAtPath:originalFullPath toPath:newFullPath error:nil];
	}
	
	// change the swf
	if ([self hasSwf]) {
		NSString *newSwf = [[newFileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"swf"];
		NSString *newPathToSwf = [[originalFullPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newSwf];
		[fm moveItemAtPath:[self pathToSwf] toPath:newPathToSwf error:nil];
	}
	
	[self willChangeValueForKey:@"path"];
    [self setPrimitiveValue:value forKey:@"path"];
    [self didChangeValueForKey:@"path"];
}

- (NSString *)expandedPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *appSupportFolder = [basePath stringByAppendingPathComponent:@"CourseBuilder"];
	return [appSupportFolder stringByAppendingPathComponent:self.path];
}

// derived and kvc properties

- (NSString *)code 
{
	return nil;
}

- (void)setCode:(NSString *)value 
{
	//
}

- (NSString *)displayName
{
	return [[self filename] stringByDeletingPathExtension];
}

- (BOOL)hasFla
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *pathToFla = [[[self expandedPath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"fla"];
	return [fm fileExistsAtPath:pathToFla];
}

- (BOOL)hasSwf
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *pathToSwf = [[[self expandedPath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swf"];
	return [fm fileExistsAtPath:pathToSwf];	
}

- (NSString *)pathToFla;
{
	return [[[self expandedPath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"fla"];
}

- (NSString *)pathToSwf;
{
	return [[[self expandedPath] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swf"];
}

// NSCoder protocols

- (NSMutableDictionary *)encode
{	
    // first get all of the values from the object
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:[[self entity] attributeKeys]] mutableCopy];
    NSDictionary *attributes = [[self entity] attributesByName];
	
    for(NSString *key in attributes)
	{
		NSAttributeDescription *attribute = [attributes objectForKey:key];
		id value = [dict objectForKey:key];
		
		if( (value == nil) || ([value isKindOfClass:[NSNull class]]) )
		{
			if([attribute attributeType] == NSStringAttributeType)
				[dict setObject:@"" forKey:key];
			else
				[dict removeObjectForKey:key];
		}
    }
	
    return [dict autorelease];
}

@end

// coalesce these into one @interface CourseFile (CoreDataGeneratedPrimitiveAccessors) section
@interface CourseFile (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveDesc;
- (void)setPrimitiveDesc:(NSString *)value;

- (NSString *)primitiveFilename;
- (void)setPrimitiveFilename:(NSString *)value;

- (NSString *)primitiveKeywords;
- (void)setPrimitiveKeywords:(NSString *)value;

- (NSString *)primitivePath;
- (void)setPrimitivePath:(NSString *)value;

- (NSString *)primitiveTitle;
- (void)setPrimitiveTitle:(NSString *)value;

- (NSString *)primitiveType;
- (void)setPrimitiveType:(NSString *)value;

@end
