//
//  CMCrashReporterGlobal.h
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.

//

#import <Cocoa/Cocoa.h>


@interface CMCrashReporterGlobal : NSObject {
}

+(void)setAppName:(NSString *)name;
+(void)setAppUiName:(NSString *)name;
+(void)setAppVersion:(NSString *)version;
+(void)setCrashReportEmail:(NSString *)emailTo;
+(void)setCrashReportURL:(NSString *)reportServerUrl;
+(void)setTechnicalDetailsAreOptional:(BOOL)optional;

@end
