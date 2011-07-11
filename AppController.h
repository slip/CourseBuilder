//
//  AppController.h
//  CourseBuilder
//
//  Created by ian kennedy on 3/2/08.
//  Copyright 2008 normal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Growl-WithInstaller/Growl.h>
#import <BWToolkitFramework/BWSplitView.h>
#import <FlashInApp/FlashInApp.h>

#import "CourseFileManager.h"
#import "Course.h"
#import "Section.h"
#import "CourseFile.h"
#import "CBTest.h"
#import "CBTemplateController.h"
#import "CBVandalay.h"

extern NSString * const CBTemplatesKey;

@class ESTreeController;
@class ESOutlineView;
@interface AppController : NSObject <GrowlApplicationBridgeDelegate>
{
	//managed object
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;

	IBOutlet NSPopUpButton *popupButton;
	IBOutlet NSMenu *popupMenu;
		
	//outline view & tree controller
	IBOutlet ESTreeController *treeController;
	IBOutlet ESOutlineView *outlineView;
		
	//toolbar item outlets
	IBOutlet NSToolbarItem *toolbarItemAddCourse;
	IBOutlet NSToolbarItem *toolbarItemAddSection;
	IBOutlet NSToolbarItem *toolbarItemNewFile;
	IBOutlet NSToolbarItem *toolbarItemAddExistingFile;
	IBOutlet NSToolbarItem *toolbarItemDeleteItem;
	IBOutlet NSToolbarItem *toolbarItemPreview;
	IBOutlet NSToolbarItem *toolbarItemBuildCourse;
	
	//menu item outlets
	IBOutlet NSMenuItem *menuItemOpenFileInFlash;
	
	//views
	IBOutlet NSWindow *window;
	IBOutlet NSView *contentView;
	IBOutlet NSView *courseView;
	IBOutlet NSView *sectionView;
	IBOutlet NSView *courseFileView;
	IBOutlet NSView *testView;
	IBOutlet NSView *splitView;
	IBOutlet NSView *templatesView;
	IBOutlet ESFlashView *swfPreview;
	
	//windows
	IBOutlet NSWindow *addCourseWindow;
	IBOutlet NSWindow *addSectionWindow;
	IBOutlet NSWindow *addFileWindow;
	IBOutlet WebView *webview;
	
	//textfields
	IBOutlet NSTextField *addCourseTitleTF;
	IBOutlet NSTextField *addCourseCodeTF;
	IBOutlet NSTextField *addCourseDescTF;
	IBOutlet NSTextField *addSectionTF;
	IBOutlet NSTextField *addFileFilenameTF;
	IBOutlet NSTextField *addFileTitleTF;
	IBOutlet NSTextField *addFileKeywordsTF;
	IBOutlet NSPopUpButton *fileTypePopUp;
	IBOutlet NSPopUpButton *courseTypePopUp;
	IBOutlet NSTextField *addFileDescriptionTF;
	
	//test tables
	IBOutlet NSObjectController *cbTestController;
	IBOutlet NSArrayController *questionsController;
	IBOutlet NSArrayController *answersController;
	IBOutlet NSTableView *questionTable;
	IBOutlet NSTableView *answerTable;
	
	//other objects
	NSManagedObject *selectedItem;
	CourseFileManager *courseFileManager;
}

- (NSDictionary *)registrationDictionaryForGrowl;

#pragma mark -
#pragma mark convenience methods
- (NSString *)pathToCourseFiles;
- (NSString *)selectedCourseCode;
- (NSString *)selectedCoursePath;
- (Course *)selectedCourse;
- (CBTest *)selectedTest;
- (NSString *)selectionType;
- (NSManagedObject *)selectedItem;
- (id)objectAtSelectedItem;
- (IBAction)saveAction:sender;

- (IBAction)deleteItem:(id)sender;

#pragma mark -
#pragma mark view controllers
- (void)swapView:(NSView *)view;

- (IBAction)showTemplates:(id)sender;
- (IBAction)newCourse:(id)sender;
- (IBAction)newSection:(id)sender;
- (IBAction)newFile:(id)sender;
- (IBAction)installJSFL:(id)sender;
- (IBAction)deleteCourse:(id)sender;
- (IBAction)deleteSection:(id)sender;
- (IBAction)deleteCourseFile:(id)sender;
- (IBAction)openSelectedFileInFlash:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)duplicateSelectedFile:(id)sender;
- (void) insertFileWithFilename:(NSString *)filename 
					   andTitle:(NSString *)title
						andDesc:(NSString *)desc 
					andKeywords:(NSString *)keywords 
						andType:(NSString *)type
						andPath:(NSString *)path;
- (NSArray *)treeNodeSortDescriptors;

// import/export
- (IBAction)importCourse:(id)sender;
- (IBAction)exportCourse:(id)sender;

// new course, section, file windows
- (IBAction)showNewCourseWindow:(id)sender;
- (IBAction)endNewCourseWindow:(id)sender;
- (IBAction)showNewSectionWindow:(id)sender;
- (IBAction)endNewSectionWindow:(id)sender;
- (IBAction)showNewFileWindow:(id)sender;
- (IBAction)endNewFileWindow:(id)sender;
- (IBAction)showExistingFileWindow:(id)sender;

-(IBAction)addQuestion:(id)sender;
-(IBAction)removeQuestion:(id)sender;
-(IBAction)addAnswer:(id)sender;
-(IBAction)removeAnswer:(id)sender;

#pragma mark -
#pragma buildCourse

- (IBAction)makeCourseGated:(id)sender;
- (IBAction)buildCourse:(id)sender;
- (IBAction)preview:(id)sender;
- (BOOL)copyCourseFolderToDesktop;
- (void)buildCourseXML;
- (void)buildImsmanifestXML;
- (void)buildTestXMLforTest:(CBTest *)postTest;
- (IBAction)archiveSourceFiles:(id)sender;
- (IBAction)goToBasecamp:(id)sender;

@end
