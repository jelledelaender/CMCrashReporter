//
//  CMCrashReporterWindow.h
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CMCrashReporterGlobal.h"


@interface CMCrashReporterWindow : NSWindowController {
	NSArray *mPaths;
	
	IBOutlet id description;
	IBOutlet id mailaddress;
	IBOutlet id commentField;
	IBOutlet id dontShowThis;
	IBOutlet id includeRapport;
	IBOutlet id application;
	IBOutlet id version;
}

+(void)runCrashReporterWithPaths:(NSArray*)paths;

-(instancetype)init;

@property (nonatomic, copy) NSArray *paths;

-(void)windowDidLoad;
-(void)windowWillClose:(NSNotification*)notification;

-(BOOL)submitFile:(NSString*)file;
-(IBAction)submitData:(id)sender;
-(IBAction)dontReport:(id)sender;

-(void)removeCrashLog:(NSString*)path;
-(NSData*)generateFormData:(NSDictionary*)dict;

@end
