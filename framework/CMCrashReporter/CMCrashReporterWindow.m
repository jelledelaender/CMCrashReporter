//
//  CMCrashReporterWindow.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporterWindow.h"
#import "CMCrashReporterGlobal.h"
#import "CMCrashReporterGlobal+private.h"

static CMCrashReporterWindow *windowController;

@implementation CMCrashReporterWindow

+(void)runCrashReporterWithPaths:(NSArray *)paths {
    if (!windowController) {
        windowController = [[self alloc] init];
    }
	[windowController setPaths:paths];
	[[windowController window] makeKeyAndOrderFront:nil];
}

#pragma mark - Default methods
-(instancetype)init {
	if ((self=[super initWithWindowNibName:NSStringFromClass([self class])])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self];
	}
	return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:self];
    [super dealloc];
}

-(NSArray*)paths {
	return mPaths;
}

-(void)setPaths:(NSArray *)paths
{
	[mPaths release];
	[paths retain];
	mPaths = paths;
}

-(void)removeCrashLog:(NSString*)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

-(void)updateIgnoreCrashes {
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	[defaults setBool:[dontShowThis state] forKey:@"CMCrashReporterIgnoreCrashes"];
}

#pragma mark - NSWindow callbacks
- (void)windowDidLoad {
    
    if (![CMCrashReporterGlobal technicalDetailsAreOptional]) {
        [includeRapport setState:1];
        [includeRapport setHidden:YES];
    }
    
    [[self window] setTitle:[NSString stringWithFormat:@"%@ - %@ (%@) ",@"CrashReport", [CMCrashReporterGlobal appUiName], [CMCrashReporterGlobal appVersion]]];
    
    NSString *email = [CMCrashReporterGlobal crashReportEmail];
    if (email) {
        [mailaddress setStringValue:email];
    }
}

-(void)windowWillClose:(NSNotification *)notification {
    [self updateIgnoreCrashes];
    
    NSUInteger i = 0;
	for (i = 0; i < [mPaths count]; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:mPaths[i]]) {
			[self removeCrashLog:mPaths[i]];
        }
	}
    
    [windowController autorelease];
    windowController = nil;
}

#pragma mark - IBAction methods
-(IBAction)submitData:(id)sender {
    NSInteger i = 0;
    BOOL failures = NO;
    NSInteger max = MIN([CMCrashReporterGlobal numberOfMaximumReports],[mPaths count]);
    
    if (max==0) {
        max=[mPaths count];
    }
    
    for (i=0;i<max;i++) {
        if ([self submitFile:mPaths[i]]) {
            // report succeed
            // File will be removed on close
        } else
            failures = YES;
    }
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[CMCrashReporterGlobal appName]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    if (!failures) {
        [alert setInformativeText:[NSString stringWithFormat:@"Thanks for helping us improve %@",[CMCrashReporterGlobal appName]]];
    } else {
        [alert setInformativeText:[NSString stringWithFormat:@"%@ was unable to send the crashlog.",[CMCrashReporterGlobal appName]]];
    }
    [alert runModal];
    [self.window close];
}

-(IBAction)dontReport:(id)sender {
    [self.window close];
}

#pragma mark - Send crash reports
-(BOOL)submitFile:(NSString *)file {
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];

    post_dict[@"type"]=@"CMCrashReporter";
    post_dict[@"application"]=[CMCrashReporterGlobal appName];
    post_dict[@"appVersion"]=[CMCrashReporterGlobal appVersion];
    post_dict[@"osVersion"]=[CMCrashReporterGlobal osVersion];
    post_dict[@"mailaddress"]=[mailaddress stringValue];
    post_dict[@"comments"]=[[commentField textStorage] string];
    post_dict[@"time"]=[[[[NSDateFormatter alloc] initWithDateFormat:@"%H:%M:%S" allowNaturalLanguage:NO] autorelease] stringFromDate:[NSDate date]];
    post_dict[@"date"]=[[[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y" allowNaturalLanguage:NO] autorelease] stringFromDate:[NSDate date]];
	
    if ([includeRapport state]) {
        post_dict[@"rapport"]=[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    } else {
        post_dict[@"rapport"]=@"not included";
    }
	
	NSData* regData = [self generateFormData:post_dict];
	[post_dict release];

	NSURL *url = [NSURL URLWithString:[CMCrashReporterGlobal crashReportURL]];
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:url];
	[post addValue: @"multipart/form-data; boundary=_insert_some_boundary_here_" forHTTPHeaderField: @"Content-Type"];
	[post setHTTPMethod: @"POST"];
	[post setHTTPBody:regData];
	
	NSURLResponse* response;
	NSError* error;
	NSData* result = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
    NSString *res = [[[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding] autorelease];
    NSString *compare = [res stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return ([compare isEqualToString:@"ok"]);
}

#pragma mark - Generate form data
-(NSData*)generateFormData:(NSDictionary*)dict {
	NSString* boundary = @"_insert_some_boundary_here_";
	NSArray* keys = [dict allKeys];
	NSMutableData* result = [[NSMutableData alloc] initWithCapacity:100];

    NSUInteger i;
	for (i=0;i<[keys count];i++)
	{
		id value = [dict valueForKey:keys[i]];
		[result appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];

		if ([value isKindOfClass:[NSString class]]) {
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\n\n", keys[i]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSASCIIStringEncoding]];
		} else if ([value isKindOfClass:[NSURL class]]) {
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", keys[i], [[value path] lastPathComponent]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: application/octet-stream\n\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		} else {
			NSLog(@"No string or NSURL for key %@ = %@ of type %@", keys[i], [dict valueForKey: keys[i]], [[dict valueForKey: keys[i]] className]);
		}
		
		[result appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	return [result autorelease];
}
@end
