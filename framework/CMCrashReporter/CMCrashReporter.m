//
//  CMCrashReporter.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporter.h"
#import "CMCrashReporterWindow.h"
#import "CMCrashReporterGlobal.h"
#import "CMCrashReporterGlobal+private.h"

@interface CMCrashReporter()
+(NSArray*)getReports;
@end

@implementation CMCrashReporter

+(void)check {
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	if ([CMCrashReporterGlobal checkOnCrashes] && ![defaults boolForKey:@"CMCrashReporterIgnoreCrashes"]) {
		NSArray *reports = [self getReports];
		if ([reports count] > 0) {
			[CMCrashReporterWindow runCrashReporterWithPaths:reports];
		}
	}
}

+(NSArray*)getReports {
    NSString *file;
    NSString *path = [@"~/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];

    NSMutableArray *array = [NSMutableArray array];
    while (file = [dirEnum nextObject]) {
        if ([file hasPrefix:[CMCrashReporterGlobal appName]]) {
            [array addObject:[[NSString stringWithFormat:@"%@/%@",path,file] stringByExpandingTildeInPath]];
        }
    }
    
    return array;
}
@end
