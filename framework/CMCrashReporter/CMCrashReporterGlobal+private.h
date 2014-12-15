//
//  CMCrashReporterGlobal+private.h
//  CMCrashReporter
//
//  Created by Ger Teunis on 15/12/14.
//  Copyright (c) 2014 VortexApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCrashReporterGlobal.h"

@interface CMCrashReporterGlobal(private)
+(NSString *)appName;
+(NSString *)appUiName;
+(NSString *)appVersion;

+(BOOL)checkOnCrashes;

+(NSString *)crashReportEmail;
+(NSString *)crashReportURL;
+(NSString *)osVersion;

+(int)numberOfMaximumReports;

+(BOOL)technicalDetailsAreOptional;
+(BOOL)getSystemVersionMajor:(unsigned *)major
minor:(unsigned *)minor
bugFix:(unsigned *)bugFix;
@end
