//
//  CMCrashReporterWindow.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporterWindow.h"

@implementation CMCrashReporterWindow

+ (void)runCrashReporterWithPaths:(NSArray *)ar
{
	CMCrashReporterWindow *windowController = [[self alloc] init];
	[windowController setPaths:ar];
	[[windowController window] makeKeyAndOrderFront:nil];
}

#pragma mark Default methods

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if (self) {
    // something to do?
	}
	return self;
}

- (NSArray *)paths {
	return paths;
}

- (void)setPaths:(NSArray *)ar
{
	[paths release];
	[ar retain];
	paths = ar;
}

- (void)windowDidLoad
{
    [includeRapport setState:1];
    [includeRapport setHidden:YES];
    
    [[self window] setTitle:[NSString stringWithFormat:@"%@ - %@ (%@) ",@"CrashReport", [CMCrashReporterGlobal appUiName],[CMCrashReporterGlobal appVersion]]];

    NSString *email = [CMCrashReporterGlobal crashReportEmail];
    if (email!=NULL)
        [mailaddress setStringValue:email];
}

- (void)removeCrashLog:(NSString *)path
{
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

- (void)updateIgnoreCrashes
{
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	[defaults setBool:[dontShowThis state] forKey:@"CMCrashReporterIgnoreCrashes"];
}

- (IBAction)submitData:(id)sender
{
    int i = 0;
	BOOL failures = NO;
    NSInteger max = MIN([CMCrashReporterGlobal numberOfMaximumReports],[paths count]);
  	
	if (max == 0) max = [paths count];
	
	for (i = 0; i < max; i++) {
		if ([self submitFile:[paths objectAtIndex:i]]) {
			// report succeed
			// File will be removed on close
		} else
			failures = YES;
	}
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:[CMCrashReporterGlobal appName]];
	[alert setAlertStyle:NSInformationalAlertStyle];
	
	if (!failures)
		[alert setInformativeText:[NSString stringWithFormat:@"Thanks for helping us improve %@",[CMCrashReporterGlobal appName]]];
	else
		[alert setInformativeText:[NSString stringWithFormat:@"%@ was unable to send the crashlog.",[CMCrashReporterGlobal appName]]];
		
	[alert runModal];
	[self close];
}

- (IBAction)dontReport:(id)sender
{
        [self close];
}

- (void)close {
	[self updateIgnoreCrashes];
	[self windowWillClose:nil];
	[[self window] performClose:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    /* Window need to close -- We remove all the reports -- */
    unsigned int i = 0;
	for (i = 0; i < [paths count]; i++) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:[paths objectAtIndex:i]])
			[self removeCrashLog:[paths objectAtIndex:i]];
	}
}

#pragma mark send

-(BOOL)submitFile:(NSString *)file
{
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];

	[post_dict setValue:@"CMCrashReporter" forKey:@"type"];
	[post_dict setValue:[CMCrashReporterGlobal appName] forKey:@"application"];
	[post_dict setValue:[CMCrashReporterGlobal appVersion] forKey:@"appVersion"];
	[post_dict setValue:[CMCrashReporterGlobal osVersion] forKey:@"osVersion"];
	[post_dict setValue:[NSString stringWithString:[mailaddress stringValue]] forKey:@"mailaddress"];
	[post_dict setValue:[NSString stringWithString:[[commentField textStorage] string]] forKey:@"comments"];
	[post_dict setValue: [[[[NSDateFormatter alloc] initWithDateFormat:@"%H:%M:%S" allowNaturalLanguage:NO] autorelease] stringFromDate:[NSDate date]] forKey:@"time"];
	[post_dict setValue: [[[[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y" allowNaturalLanguage:NO] autorelease] stringFromDate:[NSDate date]] forKey:@"date"];
	
    if ([includeRapport state]) {
//        NSLog(@"File %@ contents %@", file, [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]);
		[post_dict setValue:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] forKey:@"rapport"];
    }
	else
		[post_dict setValue:@"not included" forKey:@"rapport"];
	
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

#pragma mark Generate form data

- (NSData*)generateFormData:(NSDictionary*)dict
{
	NSString* boundary = @"_insert_some_boundary_here_";
	NSArray* keys = [dict allKeys];
	NSMutableData* result = [[NSMutableData alloc] initWithCapacity:100];

        unsigned int i;
	for (i = 0; i < [keys count]; i++) 
	{
		id value = [dict valueForKey: [keys objectAtIndex: i]];
		[result appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];

		if ([value isKindOfClass:[NSString class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\n\n", [keys objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSASCIIStringEncoding]];
		}
		else if ([value isKindOfClass:[NSURL class]])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", [keys objectAtIndex:i], [[value path] lastPathComponent]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[@"Content-Type: application/octet-stream\n\n" dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		}
		else
		{
			NSLog(@"No string or NSURL for key %@ = %@ of type %@", [keys objectAtIndex:i], [dict valueForKey: [keys objectAtIndex: i]], [[dict valueForKey: [keys objectAtIndex: i]] className]);
		}
		
		[result appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
	return [result autorelease];
}
@end
