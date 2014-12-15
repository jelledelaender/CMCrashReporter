Read Me
..:: -- -- -- -- -- -- -- -- -- -- ::..

CMCrashReporter is a group of classes,
special designed for Mac applications.

CMCrashReporter collects crash-reports
and send those to a server of the
developer, in stead of Apple.

CMCrashReporter is free and opensource.
You can edit CMCrashReporter if wanted.
If you find some bugs or have some feature requests,
please email us at info@codingmammoth.com so we can
update CMCrashReporter.

Credits
..:: -- -- -- -- -- -- -- -- -- -- ::..

CMCrashReporter is developed by
Jelle De Laender - CodingMammoth.com

Thanks to Pieter Omvlee (bohemiancoding.com)
for the GUI-support.

Compability
..:: -- -- -- -- -- -- -- -- -- -- ::..

CMCrashReporter is compatible with
Tiger, Leopard and Snow Leopard.

Depending on your project, it's compatible for
intel and PPC and GC (Garbage Collection).

Usage
..:: -- -- -- -- -- -- -- -- -- -- ::..

IMPORTANT: Link 'AddressBook.framework'
(available on the Mac-computer self) to
your project,
since this CMCrashReporter is using this.

1) Link the classes and the nib-file to your project.
2) link the addressbook.framework to your project (available on Mac OS Library)
3) At your main-class (preferable AppDelegate)
import CMCrashReporter.h and call [CMCrashReporter check].

A good place to call this method is in -(void)applicationDidFinishLaunching: in your app delegate



App Settings (info.plist)
..:: -- -- -- -- -- -- -- -- -- -- ::..

CMSubmitURL - String: HTTP-Path to commit the logs to (as POST-Data)
CMMaxReports (optional) - Int: max number of crashlogs to be sent

Settings (Preferences)
..:: -- -- -- -- -- -- -- -- -- -- ::..
It's possible to let your users have a choice to submit reports, or just ignore them.

Create a NSCheckbox and link this to NSUserDefaults with 'CMCrashReporterIgnoreCrashes' as key.

CMCrashReporterIgnoreCrashes - BOOL: let the user ignore crashreports
