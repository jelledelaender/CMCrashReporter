//
//  CMCrashReporterGlobal.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporterGlobal.h"
#import <AddressBook/AddressBook.h>


NSString* mAppName = nil;
NSString* mAppUiName = nil;
NSString* mAppVersion = nil;
NSString* mCrashReportEmail = nil;
NSString* mCrashReportEmailSubject = nil;
NSString* mCrashReportURL = nil;


@implementation CMCrashReporterGlobal


- (void)dealloc {
    if (mAppName != nil)
        [mAppName release];
    if (mAppUiName != nil)
        [mAppUiName release];
    if (mAppVersion != nil)
        [mAppVersion release];
    if (mCrashReportEmail != nil)
        [mCrashReportEmail release];
    if (mCrashReportEmailSubject != nil)
        [mCrashReportEmailSubject release];
    if (mCrashReportURL != nil)
        [mCrashReportURL release];

    [super dealloc];
}


+ (NSString *)appName
{
    if (mAppName != NULL)
        return mAppName;
    else
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString *)appUiName
{
    if (mAppUiName != NULL)
        return mAppUiName;
    else
        return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString *)appVersion
{
    if (mAppVersion != NULL)
        return mAppVersion;
    else
        return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (int)numberOfMaximumReports {
	if (! [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CMMaxReports"]) return 0;
	
	return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CMMaxReports"] intValue];
}

+ (BOOL)isRunningLeopard
{
	SInt32 MacVersion;
	Gestalt(gestaltSystemVersion, &MacVersion);
	return MacVersion >= 4176;
}

+ (BOOL)checkOnCrashes
{
	// Integration for later
	return YES;
}

+ (NSString *)crashReportURL
{
    NSString *value;
    if (mCrashReportURL != NULL)
        value = mCrashReportURL;
    else
        value = [[[NSBundle mainBundle] infoDictionary]
			objectForKey:@"CMSubmitURL"];
    if (!value) NSLog(@"Warning: No CMSubmitURL - key available for CMCrashReporter. Please add this key at your info.plist file.");
    return value;
}

+ (NSString *)crashReportEmail
{
    NSString *email;
    if (mCrashReportURL != NULL)
        email = mCrashReportEmail;
    else
    {
        ABMultiValue *emails = [[[ABAddressBook sharedAddressBook] me] valueForProperty: kABEmailProperty];
        email = (NSString *) [emails valueAtIndex: [emails indexForIdentifier: [emails primaryIdentifier]]];
     }

    return email;
}

+ (NSString *)osVersion
{
	return [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"]
			objectForKey:@"ProductVersion"];
}

+ (void)setAppName:(NSString *)name
{
    mAppName = name;
}

+ (void)setAppUiName:(NSString *)name
{
    mAppUiName = name;
}

+ (void)setAppVersion:(NSString *)version
{
    mAppVersion = version;
}

+ (void)setCrashReportEmail:(NSString *)emailTo
{
    mCrashReportEmail = emailTo;
}

+ (void)setCrashReportURL:(NSString *)reportServerUrl
{
    mCrashReportURL = reportServerUrl;
}


@end

