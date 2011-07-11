//
//  CBImporter.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 9/3/09.
//  Copyright 2009 normal software. All rights reserved.
//

#import "CBVandalay.h"

@implementation CBVandalay

- (id)init
{
	[super init];
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithCourse:(Course *)courseFromApp andDestination:(NSString *)pathToDestination
{
	self = [super init];
	course = courseFromApp;
	origin = [course path];
	destination = pathToDestination;
	fileManager = [self fileManager];
	appSupportFolder = [self appSupportFolder];
	return self;
}

- (id)initWithArchive:(NSString *)pathToArchive andContext:(NSManagedObjectContext *)moc
{
	self = [super init];
	fileManager = [self fileManager];
	appSupportFolder = [self appSupportFolder];
	vandalayMoc = moc;
	origin = pathToArchive;
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

- (BOOL)createCourseObjectPlist 
{
	// serialize the course data object
	NSMutableDictionary *courseDict = [course encode];
	BOOL success = [NSKeyedArchiver archiveRootObject:courseDict 
								toFile:[[course expandedPath] stringByAppendingPathComponent:@"courseobject.plist"]];
	return success;
}
- (BOOL)exportCourse
{
	[self convertCourse];
	
	//export the bundle
	NSString *courseAtDestination = [destination stringByAppendingPathComponent:[[course path] lastPathComponent]];

	if (![fileManager fileExistsAtPath:courseAtDestination]) 
	{
		[self copyToDestination];
	}
	else 
	{
		// create an alert telling the user it already exists and asking whether to overwrite it
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		NSString *alertText = (@"The course already exists on desktop.");
		[alert setMessageText:alertText];
		[alert setInformativeText:@"Would you like to overwrite the existing course?"];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		// run the alert
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			[fileManager removeItemAtPath:courseAtDestination error:nil];
			if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
															 source:appSupportFolder
														destination:destination
															  files:[NSArray arrayWithObject:[course.path lastPathComponent]]
																tag:NULL])
			{
				NSBeep();
				NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
				[alert release];
				return NO;
			}			
		}
		[alert release];
	}
	return YES;
}

- (BOOL)convertCourse
{
	NSString *originalPath = course.path;
	
	// update all paths
	[self updatePaths];

	// change the directory to a .cbcourse file
	if (![[originalPath pathExtension] isEqualToString:@"cbcourse"]) {
		NSError *error = nil;
		BOOL success = [fileManager moveItemAtPath:origin 
											toPath:[[origin stringByDeletingPathExtension] stringByAppendingPathExtension:@"cbcourse"] 
											 error:&error];
		
		if (!success) {
			[NSApp presentError:error];
			NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
			return NO;
		}		
	}
	
	// create the courseobject.plist
	BOOL success = [self createCourseObjectPlist];
	if (!success) {
		return NO;
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
	}
	
	// save the objects 
	[vandalayMoc save:nil];
	
	return YES;
}

- (BOOL)updatePaths 
{
	// change the course path
	[course setPath:[[[course.path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"cbcourse"]];
	
	// change the path of all coursefiles
	for (Section *section in [course children]) {
		for (CourseFile *courseFile in [section children]) {
			NSString *newPath = [[[course.path lastPathComponent] stringByAppendingPathComponent:@"coursefiles"] stringByAppendingPathComponent:[courseFile.path lastPathComponent]];
			[courseFile setPath:newPath];
		}		
	}
	return YES;
}

- (BOOL)copyToDestination 
{
	if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
													 source:appSupportFolder
												destination:destination
													  files:[NSArray arrayWithObject:[course.path lastPathComponent]]
														tag:NULL])
	{
		NSBeep();
		NSLog(@"failed: %@::%@ at line %d",[self class], NSStringFromSelector(_cmd), __LINE__);
		return NO;
	}
	return YES;
}

- (BOOL) copyArchiveFile: (NSString *) archiveFile pathToCourse: (NSString *) pathToCourse  
{
	if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
													 source:[pathToCourse stringByDeletingLastPathComponent]
												destination:appSupportFolder
													  files:[NSArray arrayWithObject:archiveFile]
														tag:NULL])
	{
		NSBeep();
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
		return NO;
	}
	return YES;
}

- (void) insertCourseIntoManagedObjectContext:(NSString *)pathToCourse  
{
	// get the data out of the plist
	NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[pathToCourse stringByAppendingPathComponent:@"courseobject.plist"]];
	
	// check to see if a course with the same code exists
	
	// create the Course object
	Course *courseNode = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:vandalayMoc];
	courseNode.title = [data valueForKey:@"title"];
	courseNode.code = [data valueForKey:@"code"];
	courseNode.desc = [data valueForKey:@"desc"];
	courseNode.path = [data valueForKey:@"path"];
	[courseNode setValue:[NSNumber numberWithBool:NO] forKey:@"isLeaf"];
	courseNode.keywords = [data valueForKey:@"keywords"];
	
	// create the sections
	for (id section in [data valueForKey:@"sections"]) {
		Section *sectionNode = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:vandalayMoc];
		sectionNode.title = [section valueForKey:@"title"];
		sectionNode.parent = [section valueForKey:@"parent"];
		sectionNode.sortIndex = [section valueForKey:@"sortIndex"];
		[sectionNode setValue:[NSNumber numberWithBool:NO] forKey:@"isLeaf"];
		[courseNode addChildrenObject:sectionNode];
		
		// create the files
		for (id cbFile in [section valueForKey:@"coursefiles"]) {
			
			// create the test
			if ([[cbFile valueForKey:@"type"] isEqualToString:@"Post Test"]) 
			{
				CBTest *fileNode = [NSEntityDescription insertNewObjectForEntityForName:@"CBTest" inManagedObjectContext:vandalayMoc];
				
				//  create the questions
				for (CBQuestion *question in [cbFile valueForKey:@"questions"]) 
				{
					CBQuestion *questionNode = [NSEntityDescription insertNewObjectForEntityForName:@"CBQuestion" inManagedObjectContext:vandalayMoc];
					Order *qOrderNode = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:vandalayMoc];
					qOrderNode.order = [question valueForKey:@"order"];
					qOrderNode.cbquestion = questionNode;
					questionNode.order = qOrderNode;
					questionNode.feedback = [question valueForKey:@"feedback"];
					questionNode.keywords = [question valueForKey:@"keywords"];
					questionNode.question = [question valueForKey:@"question"];
					
					// create the answers
					for (CBAnswer *answer in [question valueForKey:@"answers"]) 
					{
						CBAnswer *answerNode = [NSEntityDescription insertNewObjectForEntityForName:@"CBAnswer" inManagedObjectContext:vandalayMoc];
						Order *aOrderNode = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:vandalayMoc];
						aOrderNode.order = [answer valueForKey:@"order"];
						aOrderNode.cbanswer = answerNode;
						answerNode.order = aOrderNode;
						answerNode.answer = [answer valueForKey:@"answer"];
						answerNode.isCorrect = [answer valueForKey:@"isCorrect"];
						[questionNode addAnswersObject:answerNode];
					}
					[fileNode addQuestionsObject:questionNode];
				}
				
				fileNode.desc = [cbFile valueForKey:@"desc"];
				fileNode.filename = [cbFile valueForKey:@"filename"];
				fileNode.keywords = [cbFile valueForKey:@"keywords"];
				fileNode.path = [cbFile valueForKey:@"path"];
				fileNode.title = [cbFile valueForKey:@"title"];
				fileNode.type = [cbFile valueForKey:@"type"];
				fileNode.parent = [cbFile valueForKey:@"parent"];
				fileNode.sortIndex = [cbFile valueForKey:@"sortIndex"];
				[fileNode setValue:[NSNumber numberWithBool:YES] forKey:@"isLeaf"];
				[sectionNode addChildrenObject:fileNode];									
			}
			// create the files
			else 
			{
				CourseFile *fileNode = [NSEntityDescription insertNewObjectForEntityForName:@"CourseFile" inManagedObjectContext:vandalayMoc];
				fileNode.desc = [cbFile valueForKey:@"desc"];
				fileNode.filename = [cbFile valueForKey:@"filename"];
				fileNode.keywords = [cbFile valueForKey:@"keywords"];
				fileNode.path = [cbFile valueForKey:@"path"];
				fileNode.title = [cbFile valueForKey:@"title"];
				fileNode.type = [cbFile valueForKey:@"type"];
				fileNode.parent = [cbFile valueForKey:@"parent"];
				fileNode.sortIndex = [cbFile valueForKey:@"sortIndex"];
				[fileNode setValue:[NSNumber numberWithBool:YES] forKey:@"isLeaf"];
				[sectionNode addChildrenObject:fileNode];				
			}
		}
	}
	
	// insert the object into the treeController
	[treeController insert:courseNode];
	
	// save the CoreData
	[vandalayMoc save:nil];
}

- (BOOL)importCourse:(NSString *)pathToCourse
{	
	NSString *archiveFile = [pathToCourse lastPathComponent];

	// check to see if the course has a plist
	if (![fileManager fileExistsAtPath:[pathToCourse stringByAppendingPathComponent:@"courseobject.plist"]]) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		NSString *alertText = @"Something is wrong with this course. It doesn't have a course.plist. Either it is old, corrupt, or has never been exported. Regardless, I can't import this. Sorry.";
		[alert setMessageText:@"Failed to import course."];
		[alert setInformativeText:alertText];
		[alert setAlertStyle:NSWarningAlertStyle];
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			[alert release];
			return NO;
		}
		[alert release];
	}
	
	
	// check to see if a file with the same name exists
	
	if (![fileManager fileExistsAtPath:[appSupportFolder stringByAppendingPathComponent:archiveFile]]) 
	{
		// insert into moc
		[self insertCourseIntoManagedObjectContext:pathToCourse];
		
		// copy the file
		[self copyArchiveFile:archiveFile pathToCourse:pathToCourse];
	}
	
	else 
	{
		// create an alert telling the user it already exists and asking whether to overwrite it
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert addButtonWithTitle:@"Cancel"];
		NSString *alertText = (@"A course with that name already exists.");
		[alert setMessageText:alertText];
		[alert setInformativeText:@"Would you like to overwrite the existing course?"];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		// run the alert
		if ([alert runModal] == NSAlertFirstButtonReturn) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:vandalayMoc];
			[fetchRequest setEntity:entity];			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code LIKE[c] %@", [archiveFile stringByDeletingPathExtension]];
			[fetchRequest setPredicate:predicate];
			NSArray *array = [vandalayMoc executeFetchRequest:fetchRequest error:nil];
			NSManagedObject *oldCourse = [array objectAtIndex:0];
			
			// remove existing course from the moc
			[vandalayMoc deleteObject:oldCourse];
			// insert new course into moc
			[self insertCourseIntoManagedObjectContext:pathToCourse];
			// replace the existing file
			[fileManager removeItemAtPath:[appSupportFolder stringByAppendingPathComponent:archiveFile] error:nil];
			NSError *error = nil;
			BOOL success = [fileManager moveItemAtPath:pathToCourse 
												toPath:[appSupportFolder stringByAppendingPathComponent:archiveFile] 
												 error:&error];
			
			[fetchRequest release];
			if (!success) {
				[NSApp presentError:error];
				[alert release];
				return NO;
			}
		}
		[alert release];
	}
	return YES;
}
@end
