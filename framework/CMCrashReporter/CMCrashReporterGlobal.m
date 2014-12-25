//
//  CMCrashReporterGlobal.m
//  CMCrashReporter-App
//
//  Created by Jelle De Laender on 20/01/08.
//  Copyright 2008 CodingMammoth. All rights reserved.
//  Copyright 2010 CodingMammoth. Revision. All rights reserved.
//

#import "CMCrashReporterGlobal.h"
#import "CMCrashReporterGlobal+private.h"
#import <AddressBook/AddressBook.h>


NSString *mAppName = nil;
NSString *mAppUiName = nil;
NSString *mAppVersion = nil;
NSString *mCrashReportEmail = nil;
NSString *mCrashReportEmailSubject = nil;
NSString *mCrashReportURL = nil;
NSNumber *mTechnicalDetailsAreOptional;

@implementation CMCrashReporterGlobal

-(void)dealloc {
    if (mAppName) {
        [mAppName release];
    }
    if (mAppUiName) {
        [mAppUiName release];
    }
    if (mAppVersion) {
        [mAppVersion release];
    }
    if (mCrashReportEmail) {
        [mCrashReportEmail release];
    }
    if (mCrashReportEmailSubject) {
        [mCrashReportEmailSubject release];
    }
    if (mCrashReportURL) {
        [mCrashReportURL release];
    }
    if (mTechnicalDetailsAreOptional) {
        [mTechnicalDetailsAreOptional release];
    }

    [super dealloc];
}


+(NSString*)appName {
    if (mAppName != NULL) {
        return mAppName;
    } else {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    }
}

+(NSString*)appUiName {
    if (mAppUiName != NULL) {
        return mAppUiName;
    } else {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    }
}

+(NSString *)appVersion {
    if (mAppVersion != NULL) {
        return mAppVersion;
    } else {
        return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    }
}

+(int)numberOfMaximumReports {
    if ([[NSBundle mainBundle] infoDictionary][@"CMMaxReports"]) {
        return [[[NSBundle mainBundle] infoDictionary][@"CMMaxReports"] intValue];
    } else {
        return 0;
    }
}

+(BOOL)checkOnCrashes {
	return YES;
}

+(NSString*)crashReportURL {
    NSString *value;
    if (mCrashReportURL) {
        value = mCrashReportURL;
    } else {
        value = [[NSBundle mainBundle] infoDictionary][@"CMSubmitURL"];
    }
    if (!value) {
        NSLog(@"Warning: No CMSubmitURL - key available for CMCrashReporter. Please add this key at your info.plist file.");
    }
    return value;
}

+(NSString*)crashReportEmail {
    NSString *email;
    if (mCrashReportURL != NULL) {
        email = mCrashReportEmail;
    } else {
        ABMultiValue *emails = [[[ABAddressBook sharedAddressBook] me] valueForProperty: kABEmailProperty];
        email = (NSString *) [emails valueAtIndex: [emails indexForIdentifier: [emails primaryIdentifier]]];
    }

    return email;
}

+(NSString *)osVersion {
    NSInteger major, minor, bugfix;
    NSString *version;
    
    if ([self getSystemVersionMajor:&major
                              minor:&minor
                             bugFix:&bugfix]) {
        version = [NSString stringWithFormat:@"%ld.%ld.%ld", major, minor, bugfix];
    } else {
        version = @"Unknown";
    }
    return version;
}

+(BOOL)technicalDetailsAreOptional {
    BOOL value = YES;
    if (mTechnicalDetailsAreOptional) {
        value = [mTechnicalDetailsAreOptional boolValue];
    } else if ([[NSBundle mainBundle] infoDictionary][@"CMTechnicalDetailsAreOptional"]) {
        value = [((NSNumber*)[[NSBundle mainBundle] infoDictionary][@"CMTechnicalDetailsAreOptional"]) boolValue];
    }
    return value;
}

+(BOOL)getSystemVersionMajor:(NSInteger *)major
                       minor:(NSInteger *)minor
                      bugFix:(NSInteger *)bugFix;
{
    SInt32 versionMajor, versionMinor, versionBugFix;
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
        *major = version.majorVersion;
        *minor = version.minorVersion;
        *bugFix = version.patchVersion;
        
        return YES;
    } else if (Gestalt(gestaltSystemVersionMajor, &versionMajor) == noErr
               && Gestalt(gestaltSystemVersionMinor, &versionMinor) == noErr
               && Gestalt(gestaltSystemVersionBugFix, &versionBugFix) == noErr) {
        *major = versionMajor;
        *minor = versionMinor;
        *bugFix = versionBugFix;
        
        return YES;
    } else {
        return NO;
    }
}

+(void)setAppName:(NSString *)name {
    if (mAppName!=name) {
        [mAppName autorelease];
        mAppName = [name retain];
    }
}

+(void)setAppUiName:(NSString *)name {
    if (mAppUiName!=name) {
        [mAppUiName autorelease];
        mAppUiName = [name retain];
    }
}

+(void)setAppVersion:(NSString *)version {
    if (mAppVersion!=version) {
        [mAppVersion autorelease];
        mAppVersion = [version retain];
    }
}

+(void)setCrashReportEmail:(NSString *)emailTo {
    if (mCrashReportEmail!=emailTo) {
        [mCrashReportEmail autorelease];
        mCrashReportEmail = [emailTo retain];
    }
}

+(void)setCrashReportURL:(NSString *)reportServerUrl {
    if (mCrashReportURL!=reportServerUrl) {
        [mCrashReportURL autorelease];
        mCrashReportURL = [reportServerUrl retain];
    }
}

+(void)setTechnicalDetailsAreOptional:(BOOL)optional {
    if (!mTechnicalDetailsAreOptional || [mTechnicalDetailsAreOptional boolValue]!=optional) {
        [mTechnicalDetailsAreOptional autorelease];
        mTechnicalDetailsAreOptional = [NSNumber numberWithBool:optional];
    }
}

@end

