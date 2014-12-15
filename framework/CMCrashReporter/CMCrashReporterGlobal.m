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
	return [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"][@"ProductVersion"];
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

@end

