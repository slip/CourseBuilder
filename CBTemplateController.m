//
//  CBTemplateController.m
//  CourseBuilder
//
//  Created by Ian Kennedy on 12/3/08.
//  Copyright 2008 normal software. All rights reserved.
//

#import "CBTemplateController.h"


@implementation CBTemplateController

@synthesize defaultTemplates;

- (id) init
{
	if (self = [super init]) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DefaultTemplates" ofType:@"plist"];
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
											  propertyListFromData:plistXML
											  mutabilityOption:NSPropertyListMutableContainersAndLeaves
											  format:&format errorDescription:&errorDesc];
        if (!temp) {
            [errorDesc release];
        }
        self.defaultTemplates = [NSMutableArray arrayWithArray:(NSArray *)temp];
    }
    return self;
}

- (void)dealloc
{
    [path release];
	
    path = nil;
    [super dealloc];
}

- (IBAction)addTemplate:(id)sender
{
	// create the newTemplate and add it to the defaultTemplates
	NSDictionary *newTemplate;
	NSString *templateType = @"User";
	NSString *templatePath;
	NSString *newTemplatePath;
	NSString *templateName;
	NSString *pathToCustomTemplates = [[self applicationSupportFolder] stringByAppendingPathComponent:@"/_templates"];
	
	// check to see if the _templates directory exists
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathToCustomTemplates]) {
		NSLog(@"Custom templates directory doesn't exist. Creating it.");
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
		[[NSFileManager defaultManager] createDirectoryAtPath:pathToCustomTemplates attributes:nil];
	}
	
	// we want to allow selection of swfs or flas
	NSArray *fileTypes = [NSArray arrayWithObject:@"fla"];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAllowsMultipleSelection:NO];
	
	// get user input fla from an open panel
	int result = [oPanel runModalForDirectory:NSHomeDirectory()
										 file:nil
										types:fileTypes];
	
	if (result == NSOKButton) {
		NSArray *filesToAdd = [oPanel filenames];
		templatePath = [filesToAdd objectAtIndex:0];
		templateName = [[templatePath lastPathComponent] stringByDeletingPathExtension];
	}
	else 
	{
		return;
	}

	NSString *templateLastPathComponent;
	templateLastPathComponent = [templatePath lastPathComponent];
	newTemplatePath = [pathToCustomTemplates stringByAppendingPathComponent:templateLastPathComponent];
	
	// create the template dictionary using the user input
	newTemplate = [NSDictionary dictionaryWithObjectsAndKeys:templateName, @"Name", newTemplatePath, @"Path", templateType, @"Type", nil];

	// add to array controller
	[templatesController addObject:newTemplate];

	//NSLog(@"trying to copy %@ to %@.", templatePath, newTemplatePath);
	// copy the fla
	if(![[NSFileManager defaultManager] copyItemAtPath:templatePath
												toPath:newTemplatePath
												 error:nil])
	{
		NSLog(@"CBTemplateController failed to copy file.");
		NSLog(@"failed: %@::%@ at line %d", [self class], NSStringFromSelector(_cmd), __LINE__);
	}
	
	// write the plist
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DefaultTemplates" ofType:@"plist"];
	[defaultTemplates writeToFile:plistPath atomically:YES];
	
}

- (void)createTemplateFromFile:(NSString *)pathToFile
{
	// TODO: templateFromFile
}

- (IBAction)removeTemplate:(id)sender
{
	NSDictionary *selectedTemplate = [defaultTemplates objectAtIndex:[templatesTableView selectedRow]];
	
	// don't allow user to delete default templates
	if ([[selectedTemplate valueForKey:@"Type"] isEqualTo:@"Default"]) {
		NSBeep();
		return;
	}
	
	NSString *selectedPath = [selectedTemplate valueForKey:@"Path"];
	NSString *selectedFile = [selectedPath lastPathComponent];
	
	[templatesController remove:sender];
	
	// write the plist
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DefaultTemplates" ofType:@"plist"];
	[defaultTemplates writeToFile:plistPath atomically:YES];
	
	NSArray *filesToDelete = [NSArray arrayWithObject:selectedFile];
	
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:[selectedPath stringByDeletingLastPathComponent]
											destination:@""
												  files:filesToDelete
													tag:NULL];
}

- (IBAction)editTemplate:(id)sender
{
	NSString *pathToTemplates = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"flash_templates"];
	NSDictionary *selectedTemplate = [defaultTemplates objectAtIndex:[templatesTableView selectedRow]];
	NSString *selectedPath = [selectedTemplate valueForKey:@"Path"];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// if the selected template is a default template, change the path
	if ([[selectedTemplate valueForKey:@"Type"] isEqualTo:@"Default"]) {
		selectedPath = [pathToTemplates stringByAppendingPathComponent:selectedPath];
	}
	
	// open the file if it exists
	if ([fm fileExistsAtPath:selectedPath]) {
		[[NSWorkspace sharedWorkspace] openFile:selectedPath];
		return;
	}
	
	// if not, tell the user it doesn't exist
	else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"File doesn't exist"];
		[alert setInformativeText:@"That template doesn't seem to exist."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];
		return;
	}	
	
}

- (NSString *)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CourseBuilder"];
}

//=========================================================== 
//  path 
//=========================================================== 
- (NSString *)path
{
	NSDictionary *selectedTemplate = [defaultTemplates objectAtIndex:[templatesTableView selectedRow]];
	NSString *tempPath = [selectedTemplate valueForKey:@"Path"];
	if ([[selectedTemplate valueForKey:@"Type"] isEqualToString:@"Default"]) {
		path = [[[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"/flash_templates"] stringByAppendingPathComponent:tempPath];
	} else {
		path = tempPath;
	}
    return path; 
}

- (void)setPath:(NSString *)aPath
{
    if (path != aPath) {
        [path release];
        path = [aPath copy];
    }
}

//=========================================================== 
// table delegate
//=========================================================== 

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView 
{
    return self.defaultTemplates.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row 
{
    return [[defaultTemplates objectAtIndex:row] valueForKey:@"Name"];
}

//- (void)tableView:(NSTableView *)tableView 
//   setObjectValue:(id)object
//   forTableColumn:(NSTableColumn *)tableColumn 
//			  row:(NSInteger)row 
//{
//    [defaultTemplates replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:row]
//							  withObjects:[NSArray arrayWithObject:object]];
//}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if ([templatesTableView selectedRow] != -1) {
		//NSLog(@"CBTemplateController[self path] : %@", [self path]);
	}
}

@end
