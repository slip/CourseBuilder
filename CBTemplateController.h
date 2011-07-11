//
//  CBTemplateController.h
//  CourseBuilder
//
//  Created by Ian Kennedy on 12/3/08.
//  Copyright 2008 normal software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FlashInApp/FlashInApp.h>

@interface CBTemplateController : NSObject {
	NSMutableArray *defaultTemplates;
	NSString *path;
	IBOutlet NSTableView *templatesTableView;
	IBOutlet ESFlashView *flashView;
	IBOutlet NSArrayController *templatesController;
}

@property (retain, nonatomic) NSMutableArray *defaultTemplates;

- (NSString *)path;
- (void)setPath:(NSString *)aPath;
- (IBAction)addTemplate:(id)sender;
- (IBAction)removeTemplate:(id)sender;
- (IBAction)editTemplate:(id)sender;
- (void)createTemplateFromFile:(NSString *)pathToFile;
- (NSString *)applicationSupportFolder;
@end
