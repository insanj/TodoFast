/**
 
 Appigo Third Party Integration - AppigoPasteboard.m
 
 Copyright (c) 2009-2010 Appigo, Inc. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 
 */

#import "AppigoPasteboard.h"
#import "AppigoTask.h"
#import "AppigoNote.h"

// This is the name of the pasteboard used by Appigo Applications to share items
// such as tasks, notes, etc. with each other and other applications.
#define kAppigoPasteboardName			@"com.appigo.pasteboard"

// Appigo Uniform Type Identifiers (UTI).
#define kAppigoPasteboardTypeTask			@"com.appigo.task"
#define kAppigoPasteboardTypeNote			@"com.appigo.note"
#define kAppigoPasteboardTypeFillUp			@"com.appigo.fillup"

// Appigo Todo URL Import Constants
#define kAppigoTodoURLScheme				@"appigotodo://"
#define kAppigoTodoURLSchemeV2				@"appigotodov2://"
#define kAppigoTodoURLImportPath			@"/import"
#define kAppigoTodoURLPasteboardSource		@"source=pasteboard"
#define kAppigoTodoURLPasteboardName		@"pasteboard-name"

// Appigo Notebook URL Import Constants
#define kAppigoNotebookURLScheme			@"appigonotebook://"
#define kAppigoNotebookURLImportPath		@"/import"
#define kAppigoNotebookURLPasteboardSource	@"source=pasteboard"
#define kAppigoNotebookURLPasteboardName	@"pasteboard-name"


static AppigoPasteboard *_mySharedInstance = nil;
static BOOL _showErrorAlertsAutomatically = YES;
static NSString *_appStoreURL = nil;


#pragma mark -
@interface AppigoPasteboard (Private)

+ (AppigoPasteboard *)_sharedInstance;
- (id)_privateInit;

+ (void)_setTask:(AppigoTask *)task inPasteboard:(UIPasteboard *)pasteboard;
+ (void)_setNote:(AppigoNote *)note inPasteboard:(UIPasteboard *)pasteboard;

@end


#pragma mark -


@implementation AppigoPasteboard


#pragma mark -
#pragma mark Task Methods


+ (BOOL)isTodoInstalled
{
	NSURL *testURL = [[NSURL alloc] initWithString:kAppigoTodoURLScheme];
	BOOL v1Supported = [[UIApplication sharedApplication] canOpenURL:testURL];
	[testURL release];
	
	return v1Supported;
}


+ (BOOL)isTodoInstalledWith2xSupport
{
	NSURL *testURL = [[NSURL alloc] initWithString:kAppigoTodoURLSchemeV2];
	BOOL v2Supported = [[UIApplication sharedApplication] canOpenURL:testURL];
	[testURL release];
	
	return v2Supported;
}


+ (void)setTask:(AppigoTask *)task
{
	if (task == nil)
		return;
	
	// If the pasteboard exists, remove it first.  This fixes a problem we found
	// in iOS 4.0 where apps that had already used this pasteboard, stayed
	// running in the background, and use the pasteboard again were not able to
	// change the items in the pasteboard without closing the app down first.
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kAppigoPasteboardName create:NO];
	if (pasteboard != nil)
	{
		[UIPasteboard removePasteboardWithName:kAppigoPasteboardName];
	}
	
	// Create the Appigo Pasteboard and make sure it gets marked as persistent
	UIPasteboard *appigoPasteboard = [UIPasteboard pasteboardWithName:kAppigoPasteboardName create:YES];
	appigoPasteboard.persistent = YES;
	
	// Add the task to the Appigo Pasteboard
	[AppigoPasteboard _setTask:task inPasteboard:appigoPasteboard];
}


+ (AppigoTask *)task
{
	return [AppigoPasteboard taskFromPasteboardNamed:kAppigoPasteboardName];
}


+ (AppigoTask *)taskFromPasteboardNamed:(NSString *)pasteboardName
{
	if (pasteboardName == nil)
		return nil;
	
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
	if (pasteboard == nil)
		return nil;
	
	NSData *data = [pasteboard valueForPasteboardType:kAppigoPasteboardTypeTask];
	if (data == nil)
		return nil;
	
	NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	AppigoTask *task = [[[AppigoTask alloc] initWithCoder:keyedUnarchiver] autorelease];
	[keyedUnarchiver release];
	
	return task;
}


+ (BOOL)openTodoWithTask:(AppigoTask *)task
{
	if (task == nil)
	{
		NSLog(@"openTodoWithTask: called with a nil task");
		return NO;
	}
	
	// Copy the task onto the pasteboard
	NSString *importSourceAppID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *pasteboardName = [NSString stringWithFormat:@"%@.%@", kAppigoPasteboardName, importSourceAppID];
	
	// If the pasteboard exists, remove it first.  This fixes a problem we found
	// in iOS 4.0 where apps that had already used this pasteboard, stayed
	// running in the background, and use the pasteboard again were not able to
	// change the items in the pasteboard without closing the app down first.
	UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:pasteboardName create:NO];
	if (pasteBoard != nil)
	{
		[UIPasteboard removePasteboardWithName:pasteboardName];
	}
	
	UIPasteboard *importPasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
	importPasteboard.persistent = YES;
	
	[AppigoPasteboard _setTask:task inPasteboard:importPasteboard];
	
	NSMutableString *urlString = [[NSMutableString alloc] init];
	[urlString appendString:kAppigoTodoURLScheme];
	
	[urlString appendString:importSourceAppID];
	
	[urlString appendFormat:@"%@?", kAppigoTodoURLImportPath];
	[urlString appendString:kAppigoTodoURLPasteboardSource];
	[urlString appendFormat:@"&%@=%@", kAppigoTodoURLPasteboardName, pasteboardName];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	if (url == nil)
	{
		NSLog(@"Error creating import URL: %@", urlString);
		[urlString release];
		[UIPasteboard removePasteboardWithName:pasteboardName];
		return NO;
	}
	[urlString release];
	
	BOOL result = [[UIApplication sharedApplication] openURL:url];
	[url release];
	
	if (result == NO)
	{
		NSLog(@"The user does not have Todo or Todo Lite installed.");
		[UIPasteboard removePasteboardWithName:pasteboardName];
		
		if (_showErrorAlertsAutomatically == YES)
		{
#ifdef IPAD
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Todo for iPad?", @"Alert view title when a user attempts to import a task into Todo for iPad and they do not have Todo for iPad, Todo, or Todo Lite installed.")
															message:NSLocalizedString(@"Import tasks directly into Appigo Todo for iPad available on the App Store.", @"Message body of the alert to prompt a user to purchase Todo for iPad if they do not have it installed and attempt to import a task.")
#else
								  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Todo?", @"Alert view title when a user attempts to import a task into Todo and they do not have Todo or Todo Lite installed.")
																				  message:NSLocalizedString(@"Import tasks directly into Appigo Todo. Try Todo Lite free on the App Store.", @"Message body of the alert to prompt a user to purchase Todo if they do not have it installed and attempt to import a task.")
#endif
														   delegate:[AppigoPasteboard _sharedInstance]
												  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button when prompting the user to purchase Todo")
												  otherButtonTitles:NSLocalizedString(@"More Info", @"More information button used during our prompt to ask users if they'd like more information about Appigo Todo if they do not have it installed and try to import a task."), nil];
			_appStoreURL = kAppigoTodoAppStoreURL;
			[alert show];
			[alert release];
		}
		
		return NO;
	}
	
	return YES;
}


#pragma mark -
#pragma mark Note Methods

+ (void)setNote:(AppigoNote *)note
{
	if (note == nil)
		return;
	
	// If the pasteboard exists, remove it first.  This fixes a problem we found
	// in iOS 4 where apps that had already used this pasteboard, stayed
	// running in the background, and use the pasteboard again were not able to
	// change the items in the pasteboard without closing the app down first.
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kAppigoPasteboardName create:NO];
	if (pasteboard != nil)
	{
		[UIPasteboard removePasteboardWithName:kAppigoPasteboardName];
	}
	
	// Create the Appigo Pasteboard and make sure it gets marked as persistent
	UIPasteboard *appigoPasteboard = [UIPasteboard pasteboardWithName:kAppigoPasteboardName create:YES];
	appigoPasteboard.persistent = YES;
	
	// Add the note to the Appigo Pasteboard
	[AppigoPasteboard _setNote:note inPasteboard:appigoPasteboard];
}


+ (AppigoNote *)note
{
	return [AppigoPasteboard noteFromPasteboardNamed:kAppigoPasteboardName];
}


+ (AppigoNote *)noteFromPasteboardNamed:(NSString *)pasteboardName
{
	if (pasteboardName == nil)
		return nil;
	
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
	if (pasteboard == nil)
		return nil;
	
	NSData *data = [pasteboard valueForPasteboardType:kAppigoPasteboardTypeNote];
	if (data == nil)
		return nil;
	
	NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	AppigoNote *note = [[[AppigoNote alloc] initWithCoder:keyedUnarchiver] autorelease];
	[keyedUnarchiver release];
	
	return note;
}


+ (BOOL)openNotebookWithNote:(AppigoNote *)note
{
	if (note == nil)
	{
		NSLog(@"openNotebookWithNote: called with a nil note");
		return NO;
	}
	
	// Copy the task onto the pasteboard
	NSString *importSourceAppID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *pasteboardName = [NSString stringWithFormat:@"%@.%@", kAppigoPasteboardName, importSourceAppID];
	
	// If the pasteboard exists, remove it first.  This fixes a problem we found
	// in iOS 4.0 where apps that had already used this pasteboard, stayed
	// running in the background, and use the pasteboard again were not able to
	// change the items in the pasteboard without closing the app down first.
	UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:pasteboardName create:NO];
	if (pasteBoard != nil)
	{
		[UIPasteboard removePasteboardWithName:pasteboardName];
	}
	
	UIPasteboard *importPasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
	importPasteboard.persistent = YES;
	
	[AppigoPasteboard _setNote:note inPasteboard:importPasteboard];
	
	NSMutableString *urlString = [[NSMutableString alloc] init];
	[urlString appendString:kAppigoNotebookURLScheme];
	
	[urlString appendString:importSourceAppID];
	
	[urlString appendFormat:@"%@?", kAppigoNotebookURLImportPath];
	[urlString appendString:kAppigoNotebookURLPasteboardSource];
	[urlString appendFormat:@"&%@=%@", kAppigoNotebookURLPasteboardName, pasteboardName];
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	if (url == nil)
	{
		NSLog(@"Error creating import URL: %@", urlString);
		[urlString release];
		[UIPasteboard removePasteboardWithName:pasteboardName];
		return NO;
	}
	[urlString release];
	
	BOOL result = [[UIApplication sharedApplication] openURL:url];
	[url release];
	
	if (result == NO)
	{
		NSLog(@"The user does not have Notebook installed.");
		[UIPasteboard removePasteboardWithName:pasteboardName];
		
		
		if (_showErrorAlertsAutomatically == YES)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchase Notebook?", @"Alert view title when a user attempts to import a task into Notebook and they do not have it installed.")
															message:NSLocalizedString(@"Import notes directly into Appigo Notebook. See more information on the App Store.", @"Message body of the alert to prompt a user to purchase Notebook if they do not have it installed and attempt to import a note.")
														   delegate:[AppigoPasteboard _sharedInstance]
												  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button when prompting the user to purchase Notebook")
												  otherButtonTitles:NSLocalizedString(@"More Info", @"More information button used during our prompt to ask users if they'd like more information about Appigo Notebook if they do not have it installed and try to import a note."), nil];
			_appStoreURL = kAppigoNotebookAppStoreURL;
			[alert show];
			[alert release];
		}
		
		return NO;
	}
	
	return YES;
}


#pragma mark -
#pragma mark Global Settings

+ (void)setShowErrorAlertsAutomatically:(BOOL)showAlertsAutomatically
{
	_showErrorAlertsAutomatically = showAlertsAutomatically;
}


#pragma mark -
#pragma mark UIAlertViewDelegate Handler


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
		return;
	
	// The user does not have the Appigo App installed so launch them directly
	// to the App Store for more information.
	NSURL *url = [[NSURL alloc] initWithString:_appStoreURL];
	UIApplication *app = [UIApplication sharedApplication];
	[app openURL:url];
	[url release];
	[self release];
}


@end


#pragma mark -


@implementation AppigoPasteboard (Private)


+ (AppigoPasteboard *)_sharedInstance
{
	if (_mySharedInstance == nil)
	{
		_mySharedInstance = [[AppigoPasteboard alloc] _privateInit];
	}
	
	return _mySharedInstance;
}


- (id)_privateInit
{
	@synchronized(self)
	{
		if (_mySharedInstance)
		{
			[self dealloc];
		}
		else
		{
			self = [super init];
		}

	}
	
	return self;
}


+ (void)_setTask:(AppigoTask *)task inPasteboard:(UIPasteboard *)pasteboard
{
	if (task == nil)
		return;
	
	NSMutableData *taskData = [[NSMutableData alloc] init];
	NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:taskData];
	[task encodeWithCoder:keyedArchiver];
	[keyedArchiver finishEncoding];
	
	// Add the encoded task onto the Appigo Pasteboard
	NSDictionary *dictionaryItem = [[NSDictionary alloc] initWithObjectsAndKeys:
									taskData, kAppigoPasteboardTypeTask,
									nil];
	
	// Replace all pre-existing pasteboard items
	pasteboard.items = [NSArray arrayWithObject:dictionaryItem];
	[dictionaryItem release];
	[keyedArchiver release];
	[taskData release];
}


+ (void)_setNote:(AppigoNote *)note inPasteboard:(UIPasteboard *)pasteboard
{
	// Validate the note to make sure it's not nil and at least has a name
	if (note == nil)
		return;
	
	NSMutableData *noteData = [[NSMutableData alloc] init];
	NSKeyedArchiver *keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:noteData];
	[note encodeWithCoder:keyedArchiver];
	[keyedArchiver finishEncoding];
	
	// Add the items onto the Appigo Pasteboard
	NSDictionary *dictionaryItem = [[NSDictionary alloc] initWithObjectsAndKeys:
									noteData, kAppigoPasteboardTypeNote,
									nil];
	
	// Replace all pre-existing pasteboard items
	pasteboard.items = [NSArray arrayWithObject:dictionaryItem];
	[dictionaryItem release];
	[keyedArchiver release];
	[noteData release];
}


@end

