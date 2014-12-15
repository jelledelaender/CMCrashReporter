//
//  CMCrashReporter.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporter.h"

@implementation CMCrashReporter

+(void)check
{
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	if ([CMCrashReporterGlobal checkOnCrashes] && ![defaults boolForKey:@"CMCrashReporterIgnoreCrashes"]) {
		NSArray *reports = [self getReports];
		if ([reports count] > 0) {
			[CMCrashReporterWindow runCrashReporterWithPaths:reports];
		}
	}
}

+(NSArray *)getReports
{
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	
//	if ([CMCrashReporterGlobal isRunningLeopard]) {
//		// (Snow) Leopard format is AppName_Year_Month_Day
		NSString *file;
		NSString *path = [@"~/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath];
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];

		NSMutableArray *array = [NSMutableArray array];
		while (file = [dirEnum nextObject])
                        if ([file hasPrefix:[CMCrashReporterGlobal appName]])
				[array addObject:[[NSString stringWithFormat:@"%@/%@",path,file] stringByExpandingTildeInPath]];
		
		return array;
//	} else {
//		// Tiger Formet is AppName.crash.log
//		NSString *path = [[NSString stringWithFormat:@"~/Library/Logs/CrashReporter/%@.crash.log",[CMCrashReporterGlobal appName]] stringByExpandingTildeInPath];
//		if ([fileManager fileExistsAtPath:path]) return [NSArray arrayWithObject:path];
//		else return nil;
//	}
}
@end
