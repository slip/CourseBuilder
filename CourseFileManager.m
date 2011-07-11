//
//  CourseFileManager.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 3/6/08.
//  Copyright 2008 Normal Software. All rights reserved.
//

#import "CourseFileManager.h"


@implementation CourseFileManager

- (id)init
{
	[super init];
	return self;
}

- (id)initWithCourse:(Course *)aCourse
{
	self = [super init];
	course = aCourse;
	coursePath = [course expandedPath];
	courseCode = course.code;
	fileManager = [self fileManager];
	appSupportFolder = [self appSupportFolder];
	return self;
}

- (id)initWithCourseCode:(NSString *)code 
				 andType:(NSString *)type
{
	self = [super init];
	courseCode = code;
	courseType = type;
	coursePath = [courseCode stringByAppendingPathExtension:@"cbcourse"];
	fileManager = [self fileManager];
	appSupportFolder = [self appSupportFolder];
	return self;
}

- (NSFileManager *)fileManager 
{
    if (fileManager) 
	{
		return fileManager;
	}
	fileManager = [NSFileManager defaultManager];  
    return fileManager;
}

- (NSString *)appSupportFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CourseBuilder"];
}

- (void)createCourseDirectory
{	
	// create the initial directory
	[fileManager createDirectoryAtPath:[[self appSupportFolder] stringByAppendingPathComponent:coursePath]
							attributes:nil];
	
	// create the coursefiles subdirectory
	NSString *courseFilesFolder = [coursePath stringByAppendingPathComponent:@"coursefiles"];
	[fileManager createDirectoryAtPath:courseFilesFolder
								   attributes:nil];
}

- (void)deleteCourseDirectory
{
	// move the Course directory to the trash
	if ([[coursePath pathExtension] isEqualToString:@"cbcourse"]) {
		if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
														 source:[coursePath stringByDeletingLastPathComponent]
													destination:@""
														  files:[NSArray arrayWithObject:[coursePath lastPathComponent]]
															tag:NULL])
		{
			NSBeep();
			NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
		}
	}
	else 
	{
		NSString *pathToCourseFolder = [appSupportFolder stringByAppendingPathComponent:courseCode];
		NSArray *files= [NSArray arrayWithObject:[pathToCourseFolder lastPathComponent]];
		
		if ([[pathToCourseFolder stringByDeletingLastPathComponent] isEqualToString:[self appSupportFolder]]) {
			return;
		}
		
		if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
														 source:[pathToCourseFolder stringByDeletingLastPathComponent]
													destination:@""
														  files:files
															tag:NULL])
		{
			NSBeep();
			NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
		}		
	}
}

- (void) removeOrRenameFalconFiles:(NSString *)destPath  
{
	// after copying all files, remove and/or rename files
	if ([courseType isEqualToString:@"Falcon"]) {

		// remove legacy files
		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"Course.swf"]
							  error:nil];

		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"CoursePreview.swf"]
							  error:nil];
		
		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"index.html"]
								error:nil];
		
		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"preview.html"]
								error:nil];
		
		// rename falcon files
		[fileManager movePath:[destPath stringByAppendingPathComponent:@"FalconCourse.swf"]
					   toPath:[destPath stringByAppendingPathComponent:@"Course.swf"] 
					  handler:nil];

		[fileManager movePath:[destPath stringByAppendingPathComponent:@"FalconCoursePreview.swf"]
					   toPath:[destPath stringByAppendingPathComponent:@"CoursePreview.swf"] 
					  handler:nil];
		
		[fileManager movePath:[destPath stringByAppendingPathComponent:@"falcon_index.html"]
					   toPath:[destPath stringByAppendingPathComponent:@"index.html"] 
					  handler:nil];
		
		[fileManager movePath:[destPath stringByAppendingPathComponent:@"falcon_preview.html"]
					   toPath:[destPath stringByAppendingPathComponent:@"preview.html"] 
					  handler:nil];
	}
	else 
	{
		// remove FalconCourse.swf and FalconCoursePreview.swf
		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"FalconCourse.swf"]
							  error:nil];
		[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"FalconCoursePreview.swf"]
							  error:nil];
	}
}

- (void)overwriteCourseWithGatedCourse
{
	// define working folders
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *destPath = [appSupportFolder stringByAppendingPathComponent:coursePath];
	NSString *sourcePath = [[mainBundle resourcePath] stringByAppendingPathComponent:@"lmsfiles"];
		
	// remove Course.swf and CoursePreview.swf		
	[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"Course.swf"]
							error:nil];
	[fileManager removeItemAtPath:[destPath stringByAppendingPathComponent:@"CoursePreview.swf"]
							error:nil];
	
	// replace with gated swfs
	[fileManager movePath:[sourcePath stringByAppendingPathComponent:@"Course_gated.swf"]
				   toPath:[destPath stringByAppendingPathComponent:@"Course.swf"] 
				  handler:nil];
	
	[fileManager movePath:[sourcePath stringByAppendingPathComponent:@"CoursePreview_gated.swf"]
				   toPath:[destPath stringByAppendingPathComponent:@"CoursePreview.swf"] 
				  handler:nil];
	
	
}

- (void)copyLmsFiles
{
	// define working folders
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *destPath = [appSupportFolder stringByAppendingPathComponent:coursePath];
	NSString *sourcePath = [[mainBundle resourcePath] stringByAppendingPathComponent:@"lmsfiles"];
	
	// paths to lms files	
	NSArray *lmsFilePaths = [mainBundle pathsForResourcesOfType:nil
												inDirectory:@"lmsfiles"];

	// get the last path component from each file in lmsFilePaths and add it to lmsFiles
	NSMutableArray *lmsFiles = [[NSMutableArray alloc] init];
	for(NSString *path in lmsFilePaths)
	{
		[lmsFiles addObject:[path lastPathComponent]];
	}
	
	// do the copying
	NSLog(@"trying to copy these files: %@\n from this folder: %@\n to this folder: %@", lmsFiles, sourcePath, destPath);
	if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
												 source:sourcePath
											destination:destPath
												  files:lmsFiles
													tag:NULL])
	{
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
		NSBeep();
	}
	
	// add the coursefiles directory
	[fileManager createDirectoryAtPath:[destPath stringByAppendingPathComponent:@"coursefiles"] 
							attributes:nil];
	
	// remove or rename the falcon files
	[self removeOrRenameFalconFiles:destPath];

	// release the arrays
	[lmsFiles release];
}

- (void)copyFileWithPath:(NSString *)path
{
	NSString *pathToCourseFolder = [course expandedPath];
	NSString *courseFilesFolder = [pathToCourseFolder stringByAppendingPathComponent:@"coursefiles"];
	NSArray *files = [NSArray arrayWithObject:[path lastPathComponent]];
	
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
												 source:[path stringByDeletingLastPathComponent]
											destination:courseFilesFolder
												  files:files
													tag:NULL];
}

- (BOOL)buildCourseToDesktop
{
	NSString *desktopFolder = [@"~/Desktop/" stringByExpandingTildeInPath];
	NSString *courseFolderOnDesktop = [desktopFolder stringByAppendingPathComponent:courseCode];
    NSString *courseFilesFolderOnDesktop = [courseFolderOnDesktop stringByAppendingPathComponent:@"coursefiles"];
	
	// first check to see if the folder already exists on the desktop
	if ([fileManager fileExistsAtPath:courseFolderOnDesktop]) {
		
		// create an alert telling the user it already exists and asking whether to overwrite it
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		NSString *alertText = (@"The course folder already exists on desktop.");
		[alert setMessageText:alertText];
		[alert setInformativeText:@"Would you like to overwrite the existing folder?"];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		// run the alert
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			[fileManager removeItemAtPath:courseFolderOnDesktop error:nil];
            [alert release];
		}
        else {
			[alert release];
            return NO;
        }
    }

    [fileManager createDirectoryAtPath:courseFolderOnDesktop withIntermediateDirectories:NO attributes:nil error:nil];
    NSArray *courseFilesToCopy = [fileManager contentsOfDirectoryAtPath:coursePath error:nil];
    for (NSString *file in courseFilesToCopy) {
		NSString *filePath = [coursePath stringByAppendingPathComponent:file];
        BOOL success = [fileManager copyItemAtPath:filePath toPath:[courseFolderOnDesktop stringByAppendingPathComponent:file] error:nil];
		if (!success) {
			NSLog(@"tried to copy %@ to %@ and failed", filePath, [courseFolderOnDesktop stringByAppendingPathComponent:file]);
		}
    }

	NSArray *courseFiles = [fileManager contentsOfDirectoryAtPath:courseFilesFolderOnDesktop error:nil];
	
	for (NSString *file in courseFiles) {
		if ([[file pathExtension] isEqualToString:@"fla"]) {
			[fileManager removeItemAtPath:[courseFilesFolderOnDesktop stringByAppendingPathComponent:file] error:nil];
		}
		if ([[file pathExtension] isEqualToString:@"html"]) {
			[fileManager removeItemAtPath:[courseFilesFolderOnDesktop stringByAppendingPathComponent:file] error:nil];
		}
		if ([[file pathExtension] isEqualToString:@"js"]) {
			[fileManager removeItemAtPath:[courseFilesFolderOnDesktop stringByAppendingPathComponent:file] error:nil];
		}
	}
	return YES;
}


- (void)dealloc
{
	[super dealloc];
}
@end
