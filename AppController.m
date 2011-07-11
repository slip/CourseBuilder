//
//  AppController.m
//  CourseBuilder
//
//  Created by ian kennedy on 3/2/08.
//  Copyright 2008 normal. All rights reserved.
//

#import "AppController.h"
#import "ESTreeNode.h"
#import "ESGroupNode.h"
#import "ESLeafNode.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"


NSString *ESNodeIndexPathPasteBoardType = @"ESNodeIndexPathPasteBoardType";
NSString *CoreDataDragType = @"CoreDataDragType";

NSString *const CBTemplatesKey = @"CourseTemplates";

@implementation AppController

#pragma mark -
#pragma mark initialization
- (id)init
{
	[super init];
	return self;
}

- (void)awakeFromNib
{
	// register as delegate for Growl
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	// Create sort descriptor for questions and answers tables
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order.order" 
												 ascending:YES 
												  selector:@selector(compare:)];
	[sortDescriptor autorelease];
	
	// register OutlineView and TableViews for dragged types
	[outlineView registerForDraggedTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType]];
	[questionTable registerForDraggedTypes:[NSArray arrayWithObject:CoreDataDragType]];
	[questionTable setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[answerTable registerForDraggedTypes:[NSArray arrayWithObject:CoreDataDragType]];
	[answerTable setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	// itunesy selections for outlineView
	[outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	
	// outlineView doubleClickAction
	[outlineView setTarget:self];
	[outlineView setDoubleAction:@selector(openSelectedFileInFlash:)];
	
	// welcome page webview
	[webview setMainFrameURL:[[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"]];
	[contentView addSubview:webview];
//	[self swapView:webview];
	WebScriptObject *win = [webview windowScriptObject];
	[win setValue:self forKey:@"Courses"];
		
	// popupbutton stuff
	[popupButton setMenu:popupMenu];
	
}

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray *notifications;
	notifications = [NSArray arrayWithObjects:@"Course Built", @"Files Archived", @"Course Exported", @"Course Imported", nil];
	
	NSDictionary *dict;
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			notifications, GROWL_NOTIFICATIONS_ALL,
			notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
	
	return (dict);
}

+ (NSString*)applicationVersionString {
	return [[[NSBundle bundleForClass:[AppController class]] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector { 
	return NO; 
}

#pragma mark -
#pragma mark from AppDelegate
/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "CourseBuilder" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder 
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CourseBuilder"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
	NSString *xmlPath, *sqlitePath;
    NSURL *xmlUrl, *sqliteUrl;
    NSError *error;
	NSPersistentStore *xmlStore;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
	
	xmlPath = [applicationSupportFolder stringByAppendingPathComponent:@"CourseBuilder.xml"];
	sqlitePath = [applicationSupportFolder stringByAppendingPathComponent:@"CourseBuilder.cbdoc"];
	
    xmlUrl = [NSURL fileURLWithPath:xmlPath];
	sqliteUrl = [NSURL fileURLWithPath:sqlitePath];
	
	// alloc/init the psc
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

	// check to see if sqlite file exists. if it does, add it and return the psc.
	if ([fileManager fileExistsAtPath:sqlitePath]) {
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteUrl options:nil error:&error]){
			[[NSApplication sharedApplication] presentError:error];
		}
		return persistentStoreCoordinator;
	}	
	
	// add a store with the xmlUrl
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:xmlUrl options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }

	xmlStore = [persistentStoreCoordinator persistentStoreForURL:xmlUrl];

	// migrate to the sqliteStore
	if (![persistentStoreCoordinator migratePersistentStore:xmlStore toURL:sqliteUrl options:nil
 withType:NSSQLiteStoreType error:&error]) {
		[[NSApplication sharedApplication] presentError:error];
	}
		
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    NSError *error;
    int reply = NSTerminateNow;
    [[self managedObjectContext] save:&error];
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.
				
                // Typically, this process should be altered to include application-specific 
                // recovery steps.  
				
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 
				
                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
 Implementation of dealloc, to release the retained variables.
 */

- (void) dealloc {
	
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


#pragma mark -
#pragma mark delegate methods

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	// run through all of the toolbar items and enable them based on the outlineView selection
	BOOL enable = NO;
	NSString *selectionType = [self selectionType];
	
	// enable if CourseFile (new file, delete file, add existing)	
	if([selectionType isEqualToString:@"CourseFile"] || [selectionType isEqualToString:@"CBTest"])
	{
		NSArray *fileEnabledToolbarItems = [NSArray arrayWithObjects:toolbarItemNewFile,
											toolbarItemDeleteItem, toolbarItemAddExistingFile, 
											toolbarItemBuildCourse, toolbarItemPreview, nil];
		
		
		for (NSToolbarItem *item in fileEnabledToolbarItems) {
			if ([[toolbarItem itemIdentifier] isEqual:[item itemIdentifier]]) {
				enable = ([selectionType isEqualToString:@"CourseFile"]  || [selectionType isEqualToString:@"CBTest"]);
			}
		}	
	}
	
	// enable if Section (new section, delete section, new file, add existing file)	
	else if([selectionType isEqualToString:@"Section"])
	{
		NSArray *sectionEnabledToolbarItems = [NSArray arrayWithObjects:toolbarItemAddSection,
											   toolbarItemDeleteItem, toolbarItemNewFile,
											   toolbarItemAddExistingFile, toolbarItemBuildCourse, toolbarItemPreview, nil];
		
		for (NSToolbarItem *item in sectionEnabledToolbarItems) {
			if ([[toolbarItem itemIdentifier] isEqual:[item itemIdentifier]]) {
				enable = [selectionType isEqualToString:@"Section"];
			}
		}		
	}
	
	// enable if Course (new course, delete course, new section, build course)
	else if([selectionType isEqualToString:@"Course"])
	{
		NSArray *courseEnabledToolbarItems = [NSArray arrayWithObjects:toolbarItemAddCourse, 
											  toolbarItemDeleteItem, toolbarItemAddSection,
											  toolbarItemBuildCourse, toolbarItemPreview, nil];
		
		for (NSToolbarItem *item in courseEnabledToolbarItems) {
			if ([[toolbarItem itemIdentifier] isEqual:[item itemIdentifier]]) {
				enable = [selectionType isEqualToString:@"Course"];
			}
		}
	}
	
	// if nothing is selected, enable addCourse
	else if (!selectionType) {
		if ([[toolbarItem itemIdentifier] isEqual:[toolbarItemAddCourse itemIdentifier]]) {
			enable = YES;
		}
	}	
	return enable;
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	BOOL enable = YES;
	NSString *selectionType = [self selectionType];
	
	// disable open in flash unless a coursefile is selected
	if ([[item title] isEqualToString:@"Open File in Flash"]) 
	{
		enable = ([selectionType isEqualToString:@"CourseFile"] || [selectionType isEqualToString:@"CBTest"]);
	}
	
	if ([[item title] isEqualToString:@"Reveal in Finder"]) 
	{
		enable = (![selectionType isEqualTo:nil]);
	}

	if ([[item title] isEqualToString:@"Create Template"]) 
	{
		enable = ([selectionType isEqualToString:@"CourseFile"]);
	}
	
	if ([[item title] isEqualToString:@"Duplicate File"]) 
	{
		enable = ([selectionType isEqualToString:@"CourseFile"]);
	}
		
	// disable new course unless a course is selected or nothing is selected
	if ([[item title] isEqualToString:@"New Course"]) 
	{
		if (!selectionType) {
			enable = YES;
		}
		else {
			enable = [selectionType isEqualToString:@"Course"];
		}
	}
	
	// disable new section unless a course is selected or a section is selected
	if ([[item title] isEqualToString:@"New Section"]) 
	{
		if ([selectionType isEqualToString:@"Section"]) {
			enable = [selectionType isEqualToString:@"Section"];
		}
		else {
			enable = [selectionType isEqualToString:@"Course"];
		}
	}
	
	//disable new file unless a section is selected or a file is selected
	if ([[item title] isEqualToString:@"New Course File"]) 
	{
		if ([selectionType isEqualToString:@"CourseFile"]) {
			enable = ([selectionType isEqualToString:@"CourseFile"]  || 
					  [selectionType isEqualToString:@"CBTest"]);
		}
		else {
			enable = [selectionType isEqualToString:@"Section"];
		}
	}
	
	//validate preview course, build course, and archive source files
	if ([[item title] isEqualToString:@"Preview Course"] || [[item title] isEqualToString:@"Build Course"] || [[item title] isEqualToString:@"Archive Source Files"] || [[item title] isEqualToString:@"Export Course"]) 
	{
		if (!selectionType) {
			enable = NO;
		}
		else {
			enable = YES;
		}
	}
	return enable;
}

#pragma mark -
#pragma mark outlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{	
	NSString *selectionType = [[[self selectedItem] entity] name];
	//selected item is a course
	if ([selectionType isEqualToString:@"Course"]) {
		[self swapView:courseView];
	}
	//selected item is a section
	else if([selectionType isEqualToString:@"Section"]){
		[self swapView:sectionView];
	}
	//selected item is a coursefile
	else if([selectionType isEqualToString:@"CourseFile"]){
		[self swapView:courseFileView];		
	}
	// selected item is a post test
	else if([selectionType isEqualToString:@"CBTest"]){
		[cbTestController setContent:[self selectedTest]];
		[self swapView:testView];
	}
	//selected item must be nil
	else 
	{
		NSLog(@"selectionType : %@", selectionType);
		[self swapView:webview];
		return;
	}
	if (![[[[self selectedCourse] path] pathExtension] isEqualToString:@"cbcourse"]) {
		NSLog(@"converting course");
		CBVandalay *vandalay = [[CBVandalay alloc] initWithCourse:[self selectedCourse] andDestination:nil];
		[vandalay convertCourse];
		[vandalay release];
	}	
}


#pragma mark -
#pragma mark swapping views

- (void)swapView:(NSView *)view
{
	// webview isn't visible with contentView wantsLayer:YES for some reason
	// so… hack!
	if ([view isEqualTo:webview]) {
		[contentView setWantsLayer:NO];
		if ([[contentView subviews] count] < 1) {
			[contentView addSubview:view];
		}
		else {
			NSPoint origin = NSPointFromString(@"0, 0");
			[view setFrameSize:[contentView frame].size];
			[view setFrameOrigin:origin];
			[contentView replaceSubview:[[contentView subviews] lastObject] with:view];
		}		
	}
	
	else {
		if (![contentView wantsLayer]) {
			[contentView setWantsLayer:YES];
		}
		
		[contentView setWantsLayer:YES];
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		[animation setDuration:0.3f];
		[animation setType:kCATransitionFade];
		
		[[contentView layer] addAnimation:animation forKey:@"transitionViewAnimation"];
		
		if ([[contentView subviews] count] < 1) {
			[contentView addSubview:view];
		}
		else {
			NSPoint origin = NSPointFromString(@"0, 0");
			[view setFrameSize:[contentView frame].size];
			[view setFrameOrigin:origin];
			[contentView replaceSubview:[[contentView subviews] lastObject] with:view];
		}
	}
}

- (IBAction)showTemplates:(id)sender
{
	[self swapView:templatesView];
}


#pragma mark -
#pragma mark convenience methods

- (NSString *)pathToCourseFiles
{
	NSString *path = [[self selectedCoursePath] stringByAppendingPathComponent:@"coursefiles"];
	return path;
}

- (NSString *)selectionType
{
	return [[[self selectedItem] entity] name];
}

- (NSString *)selectedCourseCode
{
	return [[self selectedCourse] code];
}

- (NSString *)selectedCoursePath
{
	return [[self selectedCourse] expandedPath];
}

- (Course *)selectedCourse
{
	NSString *selectionType = [self selectionType];
	Course *tmpCourse = nil;
	
	// if selected item is a course
	if ([selectionType isEqualToString:@"Course"]) {
		tmpCourse = (Course *)[self selectedItem];
	}
	// or a section
	else if ([selectionType isEqualToString:@"Section"]) {
		tmpCourse = [[self selectedItem] valueForKeyPath:@"parent"];
	} 
	// or a file
	else if ([selectionType isEqualToString:@"CourseFile"] || [selectionType isEqualToString:@"CBTest"]) {
		NSManagedObject *tmpSection = [[self selectedItem] valueForKeyPath:@"parent"];
		tmpCourse = [tmpSection valueForKeyPath:@"parent"];
	}
	return tmpCourse;
}

- (Section *)selectedSection
{
	NSString *selectionType = [[[self selectedItem] entity] name];
	Section *tmpSection = nil;
	
	// if selected item is a section
	if ([selectionType isEqualToString:@"Section"]) {
		tmpSection = (Section *)[self selectedItem];
	}
	// or a course file
	else if ([selectionType isEqualToString:@"CourseFile"]) {
		tmpSection = [[self selectedItem] valueForKeyPath:@"parent"];
	} 
	return tmpSection;
}


- (NSManagedObject *)selectedItem
{
	selectedItem = [[outlineView itemAtRow:[outlineView selectedRow]] representedObject];
	return selectedItem;
}

- (id)objectAtSelectedItem
{
	NSString *selectionType = [[[self selectedItem] entity] name];
	if ([selectionType isEqualToString:@"Course"]) {
		return (Course *)[self selectedItem];
	}
	else if ([selectionType isEqualToString:@"Section"])
	{
		return (Section *)[self selectedItem];
	}
	else if ([selectionType isEqualToString:@"CourseFile"])
	{
		return (CourseFile *)[self selectedItem];
	}
	else if ([selectionType isEqualToString:@"CBTest"])
	{
		return (CBTest *)[self selectedItem];
	}
	else {
		return nil;
	}
}

- (IBAction)deleteItem:(id)sender
{
	if ([[self selectionType] isEqualToString:@"Course"]) {
		[self deleteCourse:nil];
	}
	else if ([[self selectionType] isEqualToString:@"Section"]) {
		[self deleteSection:nil];
	}
	else if ([[self selectionType] isEqualToString:@"CourseFile"] || [[self selectionType] isEqualToString:@"CBTest"]) {
		[self deleteCourseFile:nil];
	}
	else
	{
		// TODO: Throw an error here
		// shouldn't ever get here
	}
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

#pragma mark -
#pragma mark showing and hiding new item windows
// to be called from javascript
- (void)showNewCourseWindow
{
	[self showNewCourseWindow:nil];
}

- (IBAction)showNewCourseWindow:(id)sender
{
	
	// clear previous values
	[addCourseTitleTF setStringValue:@""];
	[addCourseCodeTF setStringValue:@""];
	[addCourseDescTF setStringValue:@""];
	
	// show the sheet
    [NSApp beginSheet:addCourseWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)endNewCourseWindow:(id)sender
{
    // Hide the sheet
    [addCourseWindow orderOut:(id)sender];
    
    // Return to normal event handling
    [NSApp endSheet:addCourseWindow];
}

- (IBAction)showNewSectionWindow:(id)sender;
{
	// clear previous values
	[addSectionTF setStringValue:@""];
	
	// show the sheet
    [NSApp beginSheet:addSectionWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)endNewSectionWindow:(id)sender;
{
	// Hide the sheet
    [addSectionWindow orderOut:(id)sender];
    
    // Return to normal event handling
    [NSApp endSheet:addSectionWindow];
}

- (IBAction)showNewFileWindow:(id)sender;
{
	// clear previous values
	[addFileFilenameTF setStringValue:@""];
	[addFileTitleTF setStringValue:@""];
	[addFileKeywordsTF setStringValue:@""];
	[addFileDescriptionTF setStringValue:@""];
	
	// show the sheet
    [NSApp beginSheet:addFileWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
}

- (IBAction)endNewFileWindow:(id)sender;
{
	// Hide the sheet
    [addFileWindow orderOut:(id)sender];
    
    // Return to normal event handling
    [NSApp endSheet:addFileWindow];
}


#pragma mark -
#pragma mark adding and removing courses

- (void) newCourseWithTitle:(NSString *)title andCode:(NSString *)code andDesc:(NSString *)desc andPath:(NSString *)path  {
	// create the object
	Course *courseNode = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:[self managedObjectContext]];
	courseNode.title = title;
	courseNode.code = code;
	courseNode.desc = desc;
	courseNode.path = path;
	
	// insert the object
	if ([[treeController selectionIndexPath] length] == 0) {
		[treeController insertObject:courseNode 
		   atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
	}
	else if ([[treeController selectionIndexPath] length] == 1) {
		[treeController insertObject:courseNode 
		   atArrangedObjectIndexPath:[[treeController selectionIndexPath] indexPathByIncrementingLastIndex]];
	}
}

- (IBAction)newCourse:(id)sender;
{
	// check to see if a course with that code exists
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code LIKE[c] %@", [addCourseCodeTF stringValue]];
	[request setPredicate:predicate];
	NSArray *array = [moc executeFetchRequest:request error:nil];
	[request release];
	
	if (array != nil && [array count] != 0) {
		//NSLog(@"array = %@", array);
		NSAlert *alert = [NSAlert alertWithMessageText:@"A course with that code already exists" 
										 defaultButton:@"OK" 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"There is already a course with the code %@. Course codes must be unique. Please change the course code.", [addCourseCodeTF stringValue]];
		[alert runModal];
		return;
	}
	
	// values from textfields
	NSString *title = [addCourseTitleTF stringValue];
	NSString *code = [addCourseCodeTF stringValue];
	NSString *desc = [addCourseDescTF stringValue];
	NSString *courseType = [[courseTypePopUp selectedItem] title];
	NSString *path = [code stringByAppendingPathExtension:@"cbcourse"];
	
	// insert into treeController
	[self newCourseWithTitle:title andCode:code andDesc:desc andPath:path];
	
	// create the initial course directory
	courseFileManager = [[CourseFileManager alloc] initWithCourseCode:code andType:courseType];
	[courseFileManager createCourseDirectory];
	[courseFileManager copyLmsFiles];
	[courseFileManager release];
	
	// hide the sheet
    [addCourseWindow orderOut:(id)sender];
    
    // return to normal event handling
	[NSApp endSheet:addCourseWindow];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (IBAction)deleteCourse:(id)sender
{	
	// create an alert telling the user it already exists and asking whether to overwrite it
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Delete course"];
	[alert addButtonWithTitle:@"Cancel"];
	NSString *alertText = (@"Whoa there. Really?");
	[alert setMessageText:alertText];
	[alert setInformativeText:@"This will delete all of the source files within the course and cannot be undone. Are you sure you want to delete this course?"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	// run the alert
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		// delete the course from the managedobjectcontext
		[[self managedObjectContext] deleteObject:[self selectedItem]];
		// delete the directory associated with the course
		courseFileManager = [[CourseFileManager alloc] initWithCourse:[self selectedCourse]];
		[courseFileManager deleteCourseDirectory];
		[courseFileManager release];		
	}
	[alert release];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (IBAction)makeCourseGated:(id)sender
{
	courseFileManager = [[CourseFileManager alloc] initWithCourse:[self selectedCourse]];
	[courseFileManager overwriteCourseWithGatedCourse];
	[courseFileManager release];
}

#pragma mark -
#pragma mark adding and removing sections

- (void)newSectionWithTitle:(NSString *)title  {
	// create the object
	Section *sectionNode = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:[self managedObjectContext]];
	sectionNode.title = title;
	
	// insert the object
	if ([[treeController selectionIndexPath] length] == 1) {
		[treeController insertObject:sectionNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
	}
	else if ([[treeController selectionIndexPath] length] == 2) {
		[treeController insertObject:sectionNode atArrangedObjectIndexPath:[[treeController selectionIndexPath] indexPathByIncrementingLastIndex]];
	}

}
- (IBAction)newSection:(id)sender;
{
	// values from textfields
	NSString *title = [addSectionTF stringValue];
	
	// insert into treeController
	[self newSectionWithTitle:title];
	
	// hide the sheet
    [addSectionWindow orderOut:(id)sender];
    
    // return to normal event handling
	[NSApp endSheet:addSectionWindow];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (IBAction)deleteSection:(id)sender
{
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Delete Section"];
	[alert addButtonWithTitle:@"Cancel"];
	NSString *alertText = (@"Are you sure?");
	[alert setMessageText:alertText];
	[alert setInformativeText:@"This will delete all source files within the section and cannot be undone. Are you sure you want to delete this Section?"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	// run the alert
	if ([alert runModal] == NSAlertFirstButtonReturn) 
	{
		// delete the section from the MOC
		[[self managedObjectContext] deleteObject:[self selectedItem]];
		// Remove all section files
		for (CourseFile *file in [(Section *)[self selectedItem] children]) {
			NSMutableArray *filesToDelete = [NSMutableArray arrayWithCapacity:2];
			
			// if there is a fla associated with the swf
			// add it to the filesToDelete array 
			if ([file hasFla]) {
				[filesToDelete addObject:[[file pathToFla] lastPathComponent]];
			}
			
			if ([file hasSwf]) {
				[filesToDelete addObject:[[file pathToSwf] lastPathComponent]];
			}
			
			// move files to the trash
			[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
														 source:[self pathToCourseFiles]
													destination:@""
														  files:filesToDelete
															tag:NULL];
		}
	}
	[alert release];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

#pragma mark -
#pragma mark adding and removing course files

- (void)newFileWithFilename:(NSString *)filename andTitle:(NSString *)title andKeywords:(NSString *)keywords andType:(NSString *)type andDesc:(NSString *)desc  
{
	// create the object
	CourseFile *courseFileNode = [NSEntityDescription insertNewObjectForEntityForName:@"CourseFile" inManagedObjectContext:[self managedObjectContext]];
	[courseFileNode setFilename:filename];
	[courseFileNode setTitle:title];
	[courseFileNode setKeywords:keywords];
	[courseFileNode setType:type];
	[courseFileNode setDesc:desc];
	[courseFileNode setPath:[[[[self selectedCourse] path] stringByAppendingPathComponent:@"coursefiles"] stringByAppendingPathComponent:filename]];
	
	// insert the object
	if ([[treeController selectionIndexPath] length] == 2) {
		[treeController insertObject:courseFileNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
	}
	else if ([[treeController selectionIndexPath] length] == 3) {
		[treeController insertObject:courseFileNode atArrangedObjectIndexPath:[[treeController selectionIndexPath] indexPathByIncrementingLastIndex]];
	}
}

- (void)newTestWithFilename:(NSString *)filename andTitle:(NSString *)title andKeywords:(NSString *)keywords andType:(NSString *)type andDesc:(NSString *)desc  
{
	// create the test and give it properties
	CBTest *testNode = [NSEntityDescription insertNewObjectForEntityForName:@"CBTest" inManagedObjectContext:[self managedObjectContext]];
	[testNode setFilename:filename];
	[testNode setTitle:title];
	[testNode setKeywords:keywords];
	[testNode setType:type];
	[testNode setDesc:desc];
	[testNode setPathToXML:[[self selectedCoursePath] stringByAppendingPathComponent:@"test.xml"]];
	[testNode setPath:[[[[self selectedCourse] path] stringByAppendingPathComponent:@"coursefiles"] stringByAppendingPathComponent:filename]];
	
	
	// create 10 questions
	int i;
	for (i = 0; i < 10; i++) {
		NSManagedObject *question = [NSEntityDescription insertNewObjectForEntityForName:@"CBQuestion" inManagedObjectContext:[self managedObjectContext]];
		[question setValue:testNode forKey:@"test"];
		NSString *questionText = [NSString stringWithFormat:@"%@. The sky is blue.", [NSNumber numberWithInt:i+1]];
		[question setValue:questionText forKey:@"question"];
		[question setValue:@"Sorry, the correct answer is D." forKey:@"feedback"];
		
		NSManagedObject *questionOrder = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:[self managedObjectContext]];
		[questionOrder setValue:[NSNumber numberWithInt:i] forKey:@"order"];
		[questionOrder setValue:question forKey:@"cbquestion"];
		[question setValue:questionOrder forKey:@"order"];
		
		// create 4 answers
		int j;
		for (j = 0; j < 4; j++) {
			NSManagedObject *answer = [NSEntityDescription insertNewObjectForEntityForName:@"CBAnswer" inManagedObjectContext:[self managedObjectContext]];
			NSManagedObject *answerOrder = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:[self managedObjectContext]];
			switch (j) {
				case 0:
					[answer setValue:@"True" forKey:@"answer"];
					[answer setValue:[NSNumber numberWithInt:1] forKey:@"isCorrect"];
					break;
				case 1:
					[answer setValue:@"False" forKey:@"answer"];
					[answer setValue:[NSNumber numberWithInt:0] forKey:@"isCorrect"];
					break;
				case 2:
					[answer setValue:@"Both a and b" forKey:@"answer"];
					[answer setValue:[NSNumber numberWithInt:0] forKey:@"isCorrect"];
					break;
				case 3:
					[answer setValue:@"None of the Above" forKey:@"answer"];
					[answer setValue:[NSNumber numberWithInt:0] forKey:@"isCorrect"];
					break;
				default:
					break;
			}
			[answerOrder setValue:[NSNumber numberWithInt:j] forKey:@"order"];
			[answerOrder setValue:answer forKey:@"cbanswer"];
			[answer setValue:answerOrder forKey:@"order"];
			[answer setValue:question forKey:@"question"];
		}
	}
	
	// insert the test into the treecontroller
	if ([[treeController selectionIndexPath] length] == 2) {
		[treeController insertObject:testNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
	}
	else if ([[treeController selectionIndexPath] length] == 3) {
		[treeController insertObject:testNode atArrangedObjectIndexPath:[[treeController selectionIndexPath] indexPathByIncrementingLastIndex]];
	}
}

- (IBAction)newFile:(id)sender;
{
	NSString *selectedTemplate = [[fileTypePopUp selectedItem] representedObject];
	NSString *filename = [addFileFilenameTF stringValue];

	// if selectedTemplate's type is separator, just get out
	if ([[selectedTemplate valueForKey:@"Type"] isEqualToString:@"Separator"]) {
		NSBeep();
		NSAlert *alert = [NSAlert alertWithMessageText:@"Choose a template." 
										 defaultButton:@"OK" 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:@"You must choose a template from the drop-down menu. Items marked with '---' are headers, not templates.", [filename stringByDeletingPathExtension]];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[addFileFilenameTF window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		return;
	}
	
	// check for a blank filename
	int fileNum = 1;

	if ([filename isEqualToString:@""]) {
		for (Section *section in [[self selectedCourse] children]) {
			for (CourseFile *file in [section children]) {
				fileNum++;
			}
		}
		
		NSString *fileNumber = [NSString stringWithFormat:@"_%d", fileNum];
		NSString *filePrefix = [[self selectedCourseCode] stringByAppendingString:fileNumber];
		filename = [filename stringByAppendingString:filePrefix];
	}
	
	// if the filename doesn't have a fla extension 
	// or has any other extension, delete the extension and add .fla
	if (![[filename pathExtension] isEqualToString:@"fla"]) {
		// delete the existing extension
		filename = [filename stringByDeletingPathExtension];
		filename = [filename stringByAppendingPathExtension:@"fla"];
	}	
	
	NSString *title = [addFileTitleTF stringValue];
	NSString *keywords = [addFileKeywordsTF stringValue];
	NSString *desc = [addFileDescriptionTF stringValue];
	NSString *newPath = [[[[self selectedCourse] path] stringByAppendingPathComponent:@"coursefiles"] stringByAppendingPathComponent:filename];
	NSString *type = [selectedTemplate valueForKey:@"Name"];
		
	// check to see if a CourseFile with that filename exists
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CourseFile" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename LIKE[c] %@ AND path LIKE[c] %@", filename, newPath];
	[request setPredicate:predicate];
	NSArray *array = [moc executeFetchRequest:request error:nil];
	
	if (array != nil && [array count] != 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"A file with that filename already exists" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There is already a file with the name %@. Since filenames must be unique, you'll need to change the filename.", [filename stringByDeletingPathExtension]];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[addFileFilenameTF window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		return;
	}
	
	// CourseFile creation and insertion
	if (![type isEqualToString:@"Post Test"]) 
	{
		// insert into treeController
		[self newFileWithFilename:filename andTitle:title andKeywords:keywords andType:type andDesc:desc];
	}
	
	// CBTest creation and insertion
	else if ([type isEqualToString:@"Post Test"]) 
	{
		[self newTestWithFilename:filename andTitle:title andKeywords:keywords andType:type andDesc:desc];

	}
	
	// copy template fla
	// paths to template flas
	NSString *tempPath = [selectedTemplate valueForKey:@"Path"];
	
	NSString *fileToCopy = [[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"/flash_templates"] stringByAppendingPathComponent:tempPath];
	NSLog(@"trying to copy %@", fileToCopy);
	NSLog(@"trying to copy to %@", [self pathToCourseFiles]);
	if(![[NSFileManager defaultManager] copyItemAtPath:fileToCopy
												toPath:[[self pathToCourseFiles] stringByAppendingPathComponent:filename]
												 error:nil])
	{
		NSBeep();
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
	}
	
	// hide the sheet
    [addFileWindow orderOut:(id)sender];
    
    // return to normal event handling
	[NSApp endSheet:addFileWindow];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (void) insertFileWithFilename:(NSString *)filename 
					   andTitle:(NSString *)title
						andDesc:(NSString *)desc 
					andKeywords:(NSString *)keywords 
						andType:(NSString *)type
						andPath:(NSString *)path 
{
	// create a new CourseFile managed object	
	NSManagedObject *newCourseFile = [NSEntityDescription
									  insertNewObjectForEntityForName:@"CourseFile"
									  inManagedObjectContext:[self managedObjectContext]];
	
	// add properties to newCourseFile from the TextViews
	[newCourseFile setValue:filename forKey:@"filename"];
	[newCourseFile setValue:title forKey:@"title"];
	[newCourseFile setValue:keywords forKey:@"keywords"];
	[newCourseFile setValue:desc forKey:@"desc"];
	[newCourseFile setValue:type forKey:@"type"];
	[newCourseFile setValue:path forKey:@"path"];
	
	// get the currently selected section and add the coursefile to it
	NSString *selectionType = [[[self selectedItem] entity] name];
	if ([selectionType isEqualToString:@"Section"]) {
		[newCourseFile setValue:[self selectedItem] forKey:@"parent"];
	}
	else 
	{
		NSManagedObject *tmpSection = [[self selectedItem] valueForKeyPath:@"parent"];
		[newCourseFile setValue:tmpSection forKey:@"parent"];
	}
	
	// add newCourseFile to the persistent store
	[[self managedObjectContext] insertObject:newCourseFile];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (void)addExistingFileWithPath:(NSString *)path
{
	NSString *filename = [path lastPathComponent];
	
	// define paths to directories
	NSString *finalPath = [[[[self selectedCourse] path] stringByAppendingPathComponent:@"coursefiles"] stringByAppendingPathComponent:filename];
	
	// copy files to courseFilesFolder
	courseFileManager = [[CourseFileManager alloc] initWithCourse:[self selectedCourse]];		
	[courseFileManager copyFileWithPath:path];
	[courseFileManager release];
	// insert files into MOC
	[self insertFileWithFilename:filename
						andTitle:@"title"
						 andDesc:@"description"
					 andKeywords:@"keywords"
						 andType:@"Previously Existing"
						 andPath:finalPath];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (IBAction)showExistingFileWindow:(id)sender
{
	// we want to allow selection of swfs or flas
	NSArray *fileTypes = [NSArray arrayWithObjects:@"swf", @"fla", nil];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAllowsMultipleSelection:YES];

	int result = [oPanel runModalForDirectory:NSHomeDirectory()
										 file:nil
										types:fileTypes];
	
	if (result == NSOKButton) {
		NSArray *filesToAdd = [oPanel filenames];
		for (NSString *file in filesToAdd) {
			[self addExistingFileWithPath:file];
		}
	}
}

- (IBAction)deleteCourseFile:(id)sender
{
	// create an alert
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Delete file"];
	[alert addButtonWithTitle:@"Cancel"];
	NSString *alertText = (@"Are you sure?");
	[alert setMessageText:alertText];
	[alert setInformativeText:@"This will delete the source file as well and cannot be undone. Are you sure you want to delete the file?"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	// run the alert
	if ([alert runModal] == NSAlertFirstButtonReturn) 
	{
		CourseFile *selectedFile = (CourseFile *)[self selectedItem];
		NSMutableArray *filesToDelete = [NSMutableArray arrayWithCapacity:2];
				
		// if there is a fla associated with the swf
		// add it to the filesToDelete array 
		if ([selectedFile hasFla]) {
			[filesToDelete addObject:[[selectedFile pathToFla] lastPathComponent]];
		}
		
		if ([selectedFile hasSwf]) {
			[filesToDelete addObject:[[selectedFile pathToSwf] lastPathComponent]];
		}
		
		// move files to the trash
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
													 source:[self pathToCourseFiles]
												destination:@""
													  files:filesToDelete
														tag:NULL];
		// remove from persistent store
		[[self managedObjectContext] deleteObject:[self selectedItem]];
	}
	[alert release];
	
	// save coredata
	[[self managedObjectContext] save:nil];
}

- (IBAction)duplicateSelectedFile:(id)sender
{
	NSFileManager *fm = [NSFileManager defaultManager];
	CourseFile *selectedFile = (id)[self selectedItem];
	NSString *duplicateDestination = @"";
	
	// duplicate the file in the filesystem
	// TODO error check the copy
	if ([selectedFile hasFla]) {
		duplicateDestination = [[[[selectedFile pathToFla] stringByDeletingPathExtension] stringByAppendingString:@"_copy"] stringByAppendingPathExtension:@"fla"];
		[fm copyItemAtPath:[selectedFile pathToFla] toPath:duplicateDestination error:nil];
	} else if ([selectedFile hasSwf]) {
		duplicateDestination = [[[[selectedFile pathToFla] stringByDeletingPathExtension] stringByAppendingString:@"_copy"] stringByAppendingPathExtension:@"swf"];
		[fm copyItemAtPath:[selectedFile pathToFla] toPath:duplicateDestination error:nil];
	}
	
	// duplicate the file in the database
	[self addExistingFileWithPath:duplicateDestination];
	
	// save the CoreData
	[[self managedObjectContext] save:nil];
}

- (IBAction)openSelectedFileInFlash:(id)sender
{	
	if ([[self selectionType] isEqualToString:@"Section"] || [[self selectionType] isEqualToString:@"Course"]) {
		NSBeep();
		return;
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	CourseFile *selectedFile = (id)[self selectedItem];
	
	if ([[selectedFile valueForKey:@"Type"] isEqualToString:@"Post Test"]) {
		CBTest *postTest = (CBTest *)selectedFile;
		[self buildTestXMLforTest:postTest];
	}
	
	// first look for a fla to open
	if ([fm fileExistsAtPath:[selectedFile pathToFla]]) {
		[[NSWorkspace sharedWorkspace] openFile:[selectedFile pathToFla]];
		return;
	}
	
	// then look for a swf to open
	else if ([fm fileExistsAtPath:[selectedFile pathToSwf]]) {
		[[NSWorkspace sharedWorkspace] openFile:[selectedFile pathToSwf]];
		return;
	}
	
	// if neither exist, run an alert
	else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"File doesn't exist"];
		NSString *infoText = [NSString stringWithFormat:@"There is neither a .swf or .fla file by the name %@ in the coursefiles folder of this course.", [selectedFile pathToFla]];
		[alert setInformativeText:infoText];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}	
}

- (IBAction)revealInFinder:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	NSString *typeOfSelection = [self selectionType];
	NSString *fileToOpen = @"";
	
	if ([typeOfSelection isEqualToString:@"CourseFile"]) 
	{
		CourseFile *selectedFile = (CourseFile *)[self selectedItem];
		if ([selectedFile hasFla]) 
		{
			fileToOpen = [selectedFile pathToFla];
		}
		else 
		{
			fileToOpen = [selectedFile pathToSwf];
		}		
	}
	else if([typeOfSelection isEqualToString:@"Course"] || [typeOfSelection isEqualToString:@"Section"])
	{
		fileToOpen = [[self selectedCourse] expandedPath];
	}
	else 
	{
		return;
	}

	
	NSURL *fileURL = [NSURL fileURLWithPath:fileToOpen];
	[ws selectFile:[fileURL path] inFileViewerRootedAtPath:nil];
}


#pragma mark -
#pragma mark CBTest methods

- (CBTest *)selectedTest
{
	if (![[self selectionType] isEqualToString:@"CBTest"]) {
		return nil;
	}
	else {
		return (CBTest *)[self selectedItem];
	}
}

-(IBAction)addQuestion:(id)sender
{	
	// create the object
	NSManagedObject *question = [NSEntityDescription insertNewObjectForEntityForName:@"CBQuestion" 
															  inManagedObjectContext:[self managedObjectContext]];

	// create and insert order
	NSManagedObject *order = [NSEntityDescription insertNewObjectForEntityForName:@"Order" 
										  inManagedObjectContext:[self managedObjectContext]];
	
	
	[question setValue:[self selectedItem] forKey:@"test"];
	[question setValue:order forKey:@"order"];
	CBTest *selectedTest = [self selectedTest];
	int numQuestions = ([[selectedTest valueForKey:@"questions"] count]-1);
	[order setValue:[NSNumber numberWithInt:numQuestions] forKey:@"order"];
	[questionsController rearrangeObjects];
	[[self managedObjectContext] save:nil];
}

-(IBAction)removeQuestion:(id)sender
{
	NSArray *selectedQuestions = [NSArray arrayWithArray:[questionsController selectedObjects]];
	[[self managedObjectContext] deleteObject:[selectedQuestions objectAtIndex:0]];
	[[self managedObjectContext] save:nil];
}

-(IBAction)addAnswer:(id)sender
{
	// create the object
	NSManagedObject *answer = [NSEntityDescription insertNewObjectForEntityForName:@"CBAnswer" 
															inManagedObjectContext:[self managedObjectContext]];
	
	// create and insert order
	NSManagedObject *order = [NSEntityDescription insertNewObjectForEntityForName:@"Order" 
														   inManagedObjectContext:[self managedObjectContext]];
	
	[answer setValue:[questionTable objectValue] forKey:@"question"];
	[answer setValue:order forKey:@"order"];
	
	NSManagedObject *selectedQuestion = [[questionsController selectedObjects] objectAtIndex:0];
	int numAnswers = [[selectedQuestion valueForKey:@"answers"] count];
	[order setValue:[NSNumber numberWithInt:numAnswers] forKey:@"order"];
	
	// insert the object
	[answersController addObject:answer];
	[answersController rearrangeObjects];
	[[self managedObjectContext] save:nil];
}

-(IBAction)removeAnswer:(id)sender
{
	NSArray *selectedAnswers = [NSArray arrayWithArray:[answersController selectedObjects]];
	[[self managedObjectContext] deleteObject:[selectedAnswers objectAtIndex:0]];
	[[self managedObjectContext] save:nil];
}

- (NSArray *)questionSortDescriptors
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}

- (NSArray *)treeNodeSortDescriptors
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}

#pragma mark -
#pragma mark import/export

- (IBAction)exportCourse:(id)sender
{
	// have the user choose a folder to save the archive
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setPrompt:@"Choose"];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:NO];
	
	int result = [openPanel runModalForDirectory:NSHomeDirectory()
											file:nil
										   types:nil];
	
	
	if (result == NSOKButton)
	{
		NSString *selectedFolder = [[openPanel filenames] objectAtIndex:0];
		CBVandalay *exporter = [[CBVandalay alloc] initWithCourse:[self selectedCourse] 
												   andDestination:selectedFolder];
		[exporter exportCourse];
		//[exporter exportCourseWithToDictionary];
		[exporter release];
		// notify the user with growl
		[GrowlApplicationBridge notifyWithTitle:@"Your course has been Exported."
									description:[NSString stringWithFormat:@"%@ has been exported to %@.", [self selectedCourseCode], [selectedFolder lastPathComponent]]
							   notificationName:@"Course Exported"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:nil];
	}
	
}

- (IBAction)importCourse:(id)sender
{
	// we want to allow selection of swfs or flas
	NSArray *fileTypes = [NSArray arrayWithObjects:@"cbcourse", nil];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseFiles:YES];
	[oPanel setCanChooseDirectories:NO];
	[oPanel setCanCreateDirectories:NO];
	
	int result = [oPanel runModalForDirectory:NSHomeDirectory()
										 file:nil
										types:fileTypes];
	
	NSString *selectedArchive;
	if (result == NSOKButton) {
		selectedArchive = [[oPanel filenames] objectAtIndex:0];
		
		CBVandalay *importer = [[CBVandalay alloc] initWithArchive:selectedArchive 
														andContext:[self managedObjectContext]];
		[importer importCourse:selectedArchive];
		[importer release];
	}
}

#pragma mark -
#pragma mark building course

- (BOOL)allFlasCompiled
{
	BOOL allCompiled;

	NSArray *sections = [NSArray arrayWithArray:[[self selectedCourse] valueForKey:@"children"]];
	NSMutableArray *flasWithoutSwfs = [[NSMutableArray alloc] init];
	
	for (Section *section in sections) {
		NSArray *courseFiles = [NSArray arrayWithArray:[section valueForKey:@"children"]];
		for (CourseFile *file in courseFiles) {
			if (![file hasSwf]) {
				[flasWithoutSwfs addObject:file];
			}
		}
	}
	
	if ([flasWithoutSwfs count] > 0) {
		NSMutableString *flasWithoutSwfsString = [NSMutableString stringWithString:@""];
		
		for (CourseFile *file in flasWithoutSwfs) {
			[flasWithoutSwfsString appendFormat:@"%@\n", [[file valueForKey:@"filename"] stringByDeletingPathExtension]];
		}
		
		NSAlert *alert = [NSAlert alertWithMessageText:@"Some files have not been compiled" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"The files listed below have not been compiled and will not appear in the course preview. Open the files in Flash and compile them with Test Movie. \n\n%@", flasWithoutSwfsString];
		
		[alert beginSheetModalForWindow:[outlineView window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		allCompiled = NO;
	}
	else {
		allCompiled = YES;
	}

	[flasWithoutSwfs release];
	return allCompiled;
}

- (IBAction)buildCourse:(id)sender
{
	if (![self allFlasCompiled]) {
		return;
	}
	
	// save data first
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return;	
    }
	else
	{
		// build the course
		[self buildCourseXML];
		[self buildImsmanifestXML];
		
		// have CourseFileManager copy the folder to the desktop
		CourseFileManager *cfm = [[CourseFileManager alloc] initWithCourse:[self selectedCourse]];
		[cfm buildCourseToDesktop];
		[cfm release];
		// [self copyCourseFolderToDesktop];

		// use growl to tell the user the course has been built
		NSString *growlDesc = [NSString stringWithFormat:@"%@ has been built and saved to your desktop.", [self selectedCourseCode]];
		[GrowlApplicationBridge notifyWithTitle:@"Course has been built"
									description:growlDesc
							   notificationName:@"Course Built"
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:nil];
	}
}

- (IBAction)preview:(id)sender
{
	if (![self allFlasCompiled]) {
		return;
	}
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
	else
	{
		[self buildCourseXML];
		
		NSString *courseFolder = [self selectedCoursePath];
		NSString *pathToPreview = [courseFolder stringByAppendingPathComponent:@"preview.html"];
		NSURL *previewURL = [[NSURL alloc] initFileURLWithPath:pathToPreview];
		[[NSWorkspace sharedWorkspace] openURL:previewURL];
		[previewURL release];		
	}
}

- (BOOL)copyCourseFolderToDesktop
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *courseFolder = [self selectedCoursePath];
	NSString *desktopFolder = [@"~/Desktop/" stringByExpandingTildeInPath];
	NSString *courseFolderOnDesktop = [desktopFolder stringByAppendingPathComponent:[self selectedCourseCode]];
	
	
	// first check to see if the folder already exists on the desktop
	if ([fm fileExistsAtPath:courseFolderOnDesktop]) {
		
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
			[fm removeItemAtPath:courseFolderOnDesktop error:nil];
		}
		[alert release];
		
		//copy folder
		if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
														 source:[self applicationSupportFolder]
													destination:desktopFolder
														  files:[NSArray arrayWithObject:[courseFolder lastPathComponent]]
															tag:NULL])
		{
			NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
			return NO;
		}
	}
	else {
		// perform the copy
		if(![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
														 source:[self applicationSupportFolder]
													destination:desktopFolder
														  files:[NSArray arrayWithObject:[courseFolder lastPathComponent]]
															tag:NULL])
		{
			NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
			return NO;
		}
	}
	// remove flas and html from coursefiles folder
	
	NSString *courseFilesFolder = [courseFolderOnDesktop stringByAppendingPathComponent:@"coursefiles"];
	NSArray *courseFiles = [fm contentsOfDirectoryAtPath:courseFilesFolder error:nil];
	
	for (NSString *file in courseFiles) {
		if ([[file pathExtension] isEqualToString:@"fla"]) {
			[fm removeItemAtPath:[courseFilesFolder stringByAppendingPathComponent:file] error:nil];
		}
		if ([[file pathExtension] isEqualToString:@"html"]) {
			[fm removeItemAtPath:[courseFilesFolder stringByAppendingPathComponent:file] error:nil];
		}
		if ([[file pathExtension] isEqualToString:@"js"]) {
			[fm removeItemAtPath:[courseFilesFolder stringByAppendingPathComponent:file] error:nil];
		}
	}
	return YES;
}

- (IBAction)archiveSourceFiles:(id)sender
{
	NSString *courseFilesFolder = [self pathToCourseFiles];
	NSArray *courseFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:courseFilesFolder error:nil];
	NSFileManager *fm = [NSFileManager defaultManager];
	// have the user choose a folder to save the archive
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setPrompt:@"Choose"];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowsMultipleSelection:NO];
	
	int result = [openPanel runModalForDirectory:NSHomeDirectory()
										 file:nil
										types:nil];
	
	NSString *selectedFolder;
	NSString *archiveFolder;
	NSString *finalFolder = @"";
	
	if (result == NSOKButton)
	{
		selectedFolder = [[openPanel filenames] objectAtIndex:0];
		archiveFolder = [[self selectedCourseCode] stringByAppendingString:@"_archive"];
		finalFolder = [selectedFolder stringByAppendingPathComponent:archiveFolder];
		
		if (!([fm fileExistsAtPath:finalFolder])) {
			//NSLog(@"folder doesn't exist at path, creating it.");
			[fm createDirectoryAtPath:finalFolder attributes:nil];
		}
		
		// copy fla files to selectedFolder
		for (NSString *file in courseFiles)
		{
			if ([[file pathExtension] isEqualToString:@"fla"])
			{
				//NSLog(@"copying to %@", [finalFolder stringByAppendingPathComponent:file]);
				[fm copyItemAtPath:[courseFilesFolder stringByAppendingPathComponent:file]
														toPath:[finalFolder stringByAppendingPathComponent:file]
														 error:nil];
			}
		}		
	}
	// notify user with growl
	NSString *growlDesc = [NSString stringWithFormat:@"Source files have been saved at: %@", finalFolder];
	[GrowlApplicationBridge notifyWithTitle:@"Course files archived" 
								description:growlDesc
						   notificationName:@"Files Archived"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

#pragma mark -
#pragma mark connectivity

- (IBAction)goToBasecamp:(id)sender
{
	NSURL *basecampURL = [[NSURL alloc] initWithString:@"http://davita.seework.com"];
	[[NSWorkspace sharedWorkspace] openURL:basecampURL];
	[basecampURL release];
}

- (IBAction)installJSFL:(id)sender
{
	// the davita mxp file
	NSString *mxpFile = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"DaVita Commands.mxp"];
	if(![[NSWorkspace sharedWorkspace] openFile:mxpFile])
	{
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
	}
	
	NSString *mxpYahooFile = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"Astra.mxp"];
	if(![[NSWorkspace sharedWorkspace] openFile:mxpYahooFile])
	{
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
	}
	
}

#pragma mark -
#pragma mark create course.xml and imsmanifest.xml and test.xml

- (void)buildCourseXML
{
	NSManagedObject *course = [self selectedCourse];

	// course node
	NSXMLElement *courseNode = [NSXMLNode elementWithName:@"course"];
	[courseNode addAttribute:[NSXMLNode attributeWithName:@"title"
											  stringValue:[course valueForKey:@"title"]]];
	[courseNode addAttribute:[NSXMLNode attributeWithName:@"keywords"
											  stringValue:@"NA"]];
	[courseNode addAttribute:[NSXMLNode attributeWithName:@"description"
											  stringValue:[course valueForKey:@"desc"]]];
	NSString *copyright = [NSString stringWithFormat:@"©2008-%@ DaVita Inc.", [[NSDate date] descriptionWithCalendarFormat:@"%Y" timeZone:nil locale:nil]];
	[courseNode addAttribute:[NSXMLNode attributeWithName:@"copyright"
											  stringValue:copyright]];
	int pageNum = 1;
	
	// section nodes
	NSSortDescriptor *sectionSort = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
																ascending:YES];
	NSArray *sectionSortDescriptors = [NSArray arrayWithObject:sectionSort];
	NSMutableArray *sections = [NSMutableArray arrayWithArray:[course valueForKey:@"children"]];
	[sectionSort release];

	for (NSManagedObject *section in [sections sortedArrayUsingDescriptors:sectionSortDescriptors]) {
		NSXMLElement *sectionNode = [NSXMLNode elementWithName:@"section"];
		[sectionNode addAttribute:[NSXMLNode attributeWithName:@"title"
												  stringValue:[section valueForKey:@"title"]]];
		[courseNode addChild:sectionNode];
		
		// page nodes
		NSSortDescriptor *pageSort = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
																 ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:pageSort];
		NSMutableArray *pages = [NSMutableArray arrayWithArray:[section valueForKey:@"children"]];
		
		
		for (NSManagedObject *page in [pages sortedArrayUsingDescriptors:sortDescriptors]) {
			if ([[page valueForKey:@"type"] isEqualToString:@"Post Test"]) {
				CBTest *postTest = (CBTest *)page;
				[self buildTestXMLforTest:postTest];
			}
			NSXMLElement *pageNode = [NSXMLNode elementWithName:@"page"];
			[pageNode addAttribute:[NSXMLNode attributeWithName:@"title"
													   stringValue:[page valueForKey:@"title"]]];
			NSString *coursefiles = @"coursefiles/";
			NSString *source = [coursefiles stringByAppendingPathComponent:[[[page valueForKey:@"filename"] stringByDeletingPathExtension] stringByAppendingPathExtension:@"swf"]];
			[pageNode addAttribute:[NSXMLNode attributeWithName:@"source"
													stringValue:source]];
			[pageNode addAttribute:[NSXMLNode attributeWithName:@"keywords"
													stringValue:[page valueForKey:@"keywords"]]];
			[pageNode addAttribute:[NSXMLNode attributeWithName:@"description"
													stringValue:[page valueForKey:@"desc"]]];
			[pageNode addAttribute:[NSXMLNode attributeWithName:@"pagenum"
													stringValue:[NSString stringWithFormat:@"%d", pageNum]]];
			[sectionNode addChild:pageNode];
			pageNum++;
		}
		[pageSort release];	
	}
	// create the xml doc from the courseNode and save it to the coursefolder
	NSXMLDocument *courseXML = [[NSXMLDocument alloc] initWithRootElement:courseNode];
	[courseXML setVersion:@"1.0"]; 
	[courseXML setCharacterEncoding:@"UTF-8"]; 
	
	NSData *xmlData = [courseXML  XMLDataWithOptions:(NSXMLDocumentIncludeContentTypeDeclaration | NSXMLNodePrettyPrint)];

	NSString *courseFolder = [self selectedCoursePath];
	NSString *pathToCourseXML = [courseFolder stringByAppendingPathComponent:@"course.xml"];
	
	[xmlData writeToFile:pathToCourseXML atomically:YES];
	
	[courseXML release];
}

- (void)buildImsmanifestXML
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// get the currently selected course to use in the title node, etc
	id course = [self selectedCourse];
	NSString *today = [[NSDate date] descriptionWithCalendarFormat:@"%m%d%y" timeZone:nil locale:nil];
	NSString *identifierString = [NSString stringWithFormat:@"%@_%@", [self selectedCourseCode], today];
	
	// start building the xml nodes
	NSXMLElement *manifest = [NSXMLNode elementWithName:@"manifest"];
	
	// add manifest attributes
	NSXMLElement *manIdentifier = [NSXMLNode attributeWithName:@"identifier" stringValue:identifierString];
	NSXMLElement *manVersion = [NSXMLNode attributeWithName:@"version" stringValue:@"1.0"];
	NSXMLElement *manXmlns = [NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.imsglobal.org/xsd/imscp_v1p1"];
	NSXMLElement *manXsi = [NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"];
	NSXMLElement *manAdlcp = [NSXMLNode attributeWithName:@"xmlns:adlcp" stringValue:@"http://www.adlnet.org/xsd/adlcp_rootv1p2"];
	NSXMLElement *manSchemaLocation = [NSXMLNode attributeWithName:@"xsi:schemalocation" stringValue:@"http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd \n\thttp://www.click2learn.com/xsd/c2l_cp_rootv1p1 c2l_cp_rootv1p1.xsd"];
	
	[manifest addAttribute:manIdentifier];
	[manifest addAttribute:manVersion];
	[manifest addAttribute:manXmlns];
	[manifest addAttribute:manXsi];
	[manifest addAttribute:manAdlcp];
	[manifest addAttribute:manC2lcp];
	[manifest addAttribute:manSchemaLocation];
		
	NSXMLElement *metadata = [NSXMLNode elementWithName:@"metadata"];
	
	NSXMLElement *schema = [NSXMLNode elementWithName:@"schema" stringValue:@"ADLSCORM"];
	NSXMLElement *schemaversion = [NSXMLNode elementWithName:@"schemaversion" stringValue:@"1.2"];	
	
	NSXMLElement *lom = [NSXMLNode elementWithName:@"lom"];
	[lom addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.imsglobal.org/xsd/imsmd_rootv1p2p1"]];
	NSXMLElement *generalNode = [NSXMLNode elementWithName:@"general"];

	// create title node
	NSXMLElement *titleNode = [NSXMLNode elementWithName:@"title"];
	NSXMLElement *titleString = [NSXMLNode elementWithName:@"langstring" stringValue:[course title]];	
	[titleString addAttribute:[NSXMLNode attributeWithName:@"xml:lang" stringValue:@"en-US"]];
	[titleNode addChild:titleString];
	
	// create description node
	NSXMLElement *descriptionNode = [NSXMLNode elementWithName:@"description"];
	NSXMLElement *descriptionString = [NSXMLNode elementWithName:@"langstring" stringValue:[course desc]];
	[descriptionString addAttribute:[NSXMLNode attributeWithName:@"xml:lang" stringValue:@"en-US"]];
	[descriptionNode addChild:descriptionString];
	
	[manifest addChild:metadata];
	[metadata addChild:schema];
	[metadata addChild:schemaversion];
	[metadata addChild:lom];
	[lom addChild:generalNode];
	[generalNode addChild:titleNode];
	[generalNode addChild:descriptionNode];
	 
	NSXMLElement *organizations = [NSXMLNode elementWithName:@"organizations"];
	[organizations addAttribute:[NSXMLNode attributeWithName:@"default"
												 stringValue:@"org_davita"]];
	
	NSXMLElement *organization = [NSXMLNode elementWithName:@"organization"];
	[organization addAttribute:[NSXMLNode attributeWithName:@"identifier"
												stringValue:@"org_davita"]];
	
	NSXMLElement *title = [NSXMLNode elementWithName:@"title"
										 stringValue:[course valueForKey:@"title"]];
	
	NSXMLElement *item = [NSXMLNode elementWithName:@"item"];
	[item addAttribute:[NSXMLNode attributeWithName:@"identifier"
												stringValue:@"item01"]];
	[item addAttribute:[NSXMLNode attributeWithName:@"identifierref"
										stringValue:@"resource"]];
	
	NSXMLElement *itemtitle = [NSXMLNode elementWithName:@"title" stringValue:[course title]];
	
	[item addChild:itemtitle];
	[organization addChild:title];
	[organization addChild:item];
	[organizations addChild:organization];
	[manifest addChild:organizations];
	
	NSXMLElement *resources = [NSXMLNode elementWithName:@"resources"];
	NSXMLElement *resource = [NSXMLNode elementWithName:@"resource"];
	[resource addAttribute:[NSXMLNode attributeWithName:@"identifier" 
											 stringValue:@"resource"]];
	[resource addAttribute:[NSXMLNode attributeWithName:@"adlcp:scormtype"
											 stringValue:@"sco"]];
	[resource addAttribute:[NSXMLNode attributeWithName:@"href"
											 stringValue:@"index.html"]];
	[resource addAttribute:[NSXMLNode attributeWithName:@"type"
											 stringValue:@"webcontent"]];
	
	NSArray *resourceFiles = [NSArray arrayWithObjects:@"index.html", @"course.swf", @"SCORM_API_wrapper.js", @"swfobject.js", nil];
	
	for (NSString *resourceFile in resourceFiles) {
		NSXMLElement *file = [NSXMLNode elementWithName:@"file"];
		[file addAttribute:[NSXMLNode attributeWithName:@"href"
											stringValue:resourceFile]];
		[resource addChild:file];
	}
	[resources addChild:resource];
	[manifest addChild:resources];
	
	// click2learn specific
//	NSXMLElement *itemDataExtra = [NSXMLNode elementWithName:@"c2lcp:ItemDataExtra"];
//	NSXMLElement *itemData = [NSXMLNode elementWithName:@"c2lcp:ItemData"];
//	[itemData addAttribute:[NSXMLNode attributeWithName:@"identifier" stringValue:@"ID"]];
//	[itemData addAttribute:[NSXMLNode attributeWithName:@"Type" stringValue:@"Course"]];
//	NSXMLElement *itemSpecificData = [NSXMLNode elementWithName:@"c2lcp:ItemSpecificData"];
//	NSXMLElement *courseData = [NSXMLNode elementWithName:@"c2lcp:CourseData"];
//	NSXMLElement *packageProperties = [NSXMLNode elementWithName:@"c2lcp:PackageProperties"];
//	NSXMLElement *courseDisplay = [NSXMLNode elementWithName:@"c2lcp:CourseDisplay"];
//	NSXMLElement *showNavBar = [NSXMLNode elementWithName:@"c2lcp:ShowNavBar" stringValue:@"no"];
//	NSXMLElement *launchNode = [NSXMLNode elementWithName:@"c2lcp:Launch"];
//	NSXMLElement *widthNode = [NSXMLNode elementWithName:@"c2lcp:Width" stringValue:@"1024"];
//	NSXMLElement *heightNode = [NSXMLNode elementWithName:@"c2lcp:Height" stringValue:@"768"];
//	NSXMLElement *resizeNode = [NSXMLNode elementWithName:@"c2lcp:AllowResize" stringValue:@"yes"];

	
	// add elements to itemDataExtra
	[itemDataExtra addChild:itemData];
	[itemData addChild:itemSpecificData];
	[itemSpecificData addChild:courseData];
	[courseData addChild:packageProperties];
	[packageProperties addChild:courseDisplay];
	[courseDisplay addChild:showNavBar];
	[launchNode addChild:widthNode];
	[launchNode addChild:heightNode];
	[launchNode addChild:resizeNode];
	[packageProperties addChild:launchNode];
	
	// add itemDataExtra to manifest
	[manifest addChild:itemDataExtra];
	
	NSXMLDocument *manifestXML = [[NSXMLDocument alloc] initWithRootElement:manifest];
	[manifestXML setVersion:@"1.0"]; 
	[manifestXML setCharacterEncoding:@"UTF-8"]; 
	[manifestXML setDocumentContentKind:NSXMLDocumentXMLKind];
	[manifestXML setStandalone:NO];
	NSData *xmlData = [manifestXML XMLDataWithOptions:(NSXMLDocumentIncludeContentTypeDeclaration | NSXMLNodePrettyPrint)];

	NSString *courseFolder = [self selectedCoursePath];
	NSString *pathToManifestXML = [courseFolder stringByAppendingPathComponent:@"imsmanifest.xml"];
	
	[xmlData writeToFile:pathToManifestXML atomically:YES];
	[manifestXML release];
	[pool release];
}

- (void)buildTestXMLforTest:(CBTest *)postTest
{
	
	// TEST node
	NSXMLElement *testNode = (NSXMLElement *)[NSXMLNode elementWithName:@"TEST"];
	[testNode addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:[postTest valueForKey:@"title"]]];
	[testNode addAttribute:[NSXMLNode attributeWithName:@"passingScore" stringValue:[postTest valueForKey:@"passingScore"]]];
	
	// TEST_ITEM nodes
	NSMutableArray *testItems = [[NSMutableArray alloc] init];
	for (id item in [postTest valueForKey:@"questions"]) {
		[testItems addObject:item];
	}
	// set up sort descriptors
	NSSortDescriptor *testItemSD = [[NSSortDescriptor alloc] initWithKey:@"order.order"
																   ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:testItemSD];	
	NSArray *sortedTestItems = [testItems sortedArrayUsingDescriptors:sortDescriptors];
	[testItemSD release];
	[testItems release];
	
	// loop over testItems
	for(id item in sortedTestItems){
		NSXMLElement *testItem = [NSXMLNode elementWithName:@"TEST_ITEM"];
		[testItem addAttribute:[NSXMLNode attributeWithName:@"question" stringValue:[item valueForKey:@"question"]]];
		[testItem addAttribute:[NSXMLNode attributeWithName:@"feedback" stringValue:[item valueForKey:@"feedback"]]];
		[testItem addAttribute:[NSXMLNode attributeWithName:@"keywords" stringValue:[item valueForKey:@"keywords"]]];
		[testNode addChild:testItem];
		
		// ANSWER nodes
		NSMutableArray *answers = [[NSMutableArray alloc] init];
		for (id answer in [item valueForKey:@"answers"]) {
			[answers addObject:answer];
		}
		NSArray *sortedAnswers = [answers sortedArrayUsingDescriptors:sortDescriptors];
		[answers release];
		
		// loop over sortedanswers
		for(id answer in sortedAnswers)
		{
			//NSLog(@"answer: %@", answer);
			NSXMLElement *answernode =  [NSXMLNode elementWithName:@"ANSWER"];
			if (([answer valueForKey:@"isCorrect"] != nil) && ([[answer valueForKey:@"isCorrect"] isEqualToNumber:[NSNumber numberWithInt:1]])) {
				[answernode addAttribute:[NSXMLNode attributeWithName:@"correct"
														  stringValue:@"y"]];
			}
			[answernode setStringValue:[answer valueForKey:@"answer"]];
			[testItem addChild:answernode];					
		}
	}
	
	
	// create the xml doc from the testNode and save it to the coursefolder
	NSXMLDocument *testXML = [[NSXMLDocument alloc] initWithRootElement:testNode];	
	NSData *xmlData = [testXML  XMLDataWithOptions:(NSXMLNodePrettyPrint)];
	
	NSString *courseFolder = [self selectedCoursePath];
	NSString *pathToTestXML = [courseFolder stringByAppendingPathComponent:@"test.xml"];
	
	[xmlData writeToFile:pathToTestXML atomically:YES];
	
	[testXML release];
}

@end

#pragma mark -
#pragma mark outlineView delegate methods

@implementation AppController (NSOutlineViewDragAndDrop)

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteBoard;
{
	[pasteBoard declareTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType] owner:self];
	[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:ESNodeIndexPathPasteBoardType];
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView 
				  validateDrop:(id < NSDraggingInfo >)info 
				  proposedItem:(id)proposedParentItem 
			proposedChildIndex:(NSInteger)proposedChildIndex;
{
	if (proposedChildIndex == NSOutlineViewDropOnItemIndex) // will be -1 if the mouse is hovering over a leaf node
		return NSDragOperationNone;
	
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	BOOL targetIsValid = YES;
	for (NSIndexPath *indexPath in draggedIndexPaths) {
		NSTreeNode *node = [treeController nodeAtIndexPath:indexPath];
		// allow courses to be dragged and dropped
		if ([[treeController selectionIndexPath] length] == 1 && proposedParentItem == nil) {
			targetIsValid = YES;
			break;
		}
		// can't drop a file on anything but a section
		if (![proposedParentItem isSiblingOfNode:[node parentNode]]) {
			targetIsValid = NO;
			break;
		}
		
	}
	return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)proposedParentItem childIndex:(NSInteger)proposedChildIndex;
{
	NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	
	NSMutableArray *draggedNodes = [NSMutableArray array];
	for (NSIndexPath *indexPath in droppedIndexPaths)
		[draggedNodes addObject:[treeController nodeAtIndexPath:indexPath]];
	
	NSIndexPath *proposedParentIndexPath;
	if (!proposedParentItem)
		proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
	else
		proposedParentIndexPath = [proposedParentItem indexPath];
	
	[treeController moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
	return YES;
}

@end

@implementation AppController (NSTableViewDragAndDrop)
- (BOOL)tableView:(NSTableView*)tableView 
        writeRows:(NSArray*)rows 
	 toPasteboard:(NSPasteboard*)pboard
{
    // Get array controller
    NSDictionary*       bindingInfo;
    NSArrayController*  arrayController;
    bindingInfo = [tableView infoForBinding:NSContentBinding];
    arrayController = [bindingInfo valueForKey:NSObservedObjectKey];
    
    // Get arranged objects, they are managed object
    NSArray*    arrangedObjects;
    arrangedObjects = [arrayController arrangedObjects];
    
    // Collect URI representation of managed objects
    NSMutableArray* objectURIs;
    NSEnumerator*   enumerator;
    NSNumber*       rowNumber;
    objectURIs = [NSMutableArray array];
    enumerator = [rows objectEnumerator];
    while (rowNumber = [enumerator nextObject]) {
        int row;
        row = [rowNumber intValue];
        if (row >= [arrangedObjects count]) {
            continue;
        }
        
        // Get URI representation of managed object
        NSManagedObject*    object;
        NSManagedObjectID*  objectID;
        NSURL*              objectURI;
        object = [arrangedObjects objectAtIndex:row];
        objectID = [object objectID];
        objectURI = [objectID URIRepresentation];
        
        [objectURIs addObject:objectURI];
    }
    
    // Set them to paste board
    [pboard declareTypes:[NSArray arrayWithObject:CoreDataDragType] owner:nil];
    [pboard setData:[NSArchiver archivedDataWithRootObject:objectURIs] forType:CoreDataDragType];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView 
				validateDrop:(id <NSDraggingInfo>)info 
				 proposedRow:(int)row 
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (operation == NSTableViewDropOn) {
        [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    }
    
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tableView 
	   acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)row 
	dropOperation:(NSTableViewDropOperation)operation
{
    // Get object URIs from paste board
    NSData*     data;
    NSArray*    objectURIs;
    data = [[info draggingPasteboard] dataForType:CoreDataDragType];
    objectURIs = [NSUnarchiver unarchiveObjectWithData:data];
    if (!objectURIs) {
        return NO;
    }
    
    // Get array controller
    NSDictionary*       bindingInfo;
    NSArrayController*  arrayController;
    bindingInfo = [tableView infoForBinding:@"content"];
    arrayController = [bindingInfo valueForKey:NSObservedObjectKey];
    
    // Get managed object context and persistent store coordinator
    NSManagedObjectContext *context = [self managedObjectContext];
	NSPersistentStoreCoordinator *coordinator = [context persistentStoreCoordinator];
    
    // Collect manged objects with URIs
    NSMutableArray*		draggedObjects;
    NSEnumerator*		enumerator;
    NSURL*				objectURI;
	NSManagedObjectID*  objectID;
	NSManagedObject*    object;
    draggedObjects = [NSMutableArray array];
    enumerator = [objectURIs objectEnumerator];
    while (objectURI = [enumerator nextObject]) {
        // Get managed object
        objectID = [coordinator managedObjectIDForURIRepresentation:objectURI];
        object = [context objectWithID:objectID];
        if (!object) {
            continue;
        }
        
        [draggedObjects addObject:object];
    }
    
	// Get managed objects
	NSMutableArray*	objects;
	objects = [NSMutableArray arrayWithArray:[arrayController arrangedObjects]];
	if (!objects || [objects count] == 0) {
		return NO;
	}
	
	// Replace dragged objects with null objects as placeholder
	enumerator = [draggedObjects objectEnumerator];
	while (object = [enumerator nextObject]) {
		int	index;
		index = [objects indexOfObject:object];
		if (index == NSNotFound) {
			// Error
			//NSLog(@"Not found dragged link in links");
			continue;
		}
		
		[objects replaceObjectAtIndex:index withObject:[NSNull null]];
	}
	
	// Insert dragged objects at row
	if (row < [objects count]) {
		[objects insertObjects:draggedObjects 
					 atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, [draggedObjects count])]];
	}
	else {
		[objects addObjectsFromArray:draggedObjects];
	}
	
	// Remove null objeccts
	[objects removeObject:[NSNull null]];
	
	// Re-order objects
	int	i;
	for (i = 0; i < [objects count]; i++) {
		object = [objects objectAtIndex:i];
		[object setValue:[NSNumber numberWithInt:i] forKeyPath:@"order.order"];
	}
	
	// Reload data
	[arrayController rearrangeObjects];
	
    return YES;
}
@end

@implementation AppController (NSOutlineViewDelegate)
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] isSpecialGroup] boolValue];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canCollapse] boolValue];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canExpand] boolValue];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	return [[(ESTreeNode *)[item representedObject] isSelectable] boolValue];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{
	ESGroupNode *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	collapsedItem.isExpanded = [NSNumber numberWithBool:NO];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	ESGroupNode *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	expandedItem.isExpanded = [NSNumber numberWithBool:YES];
}
@end
