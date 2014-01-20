/**

 Appigo Third Party Integration - AppigoPasteboard.h
 
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



/**
 @file AppigoPasteboard.h
 @brief A convenience class for importing tasks and notes into Appigo Todo and Appigo Notebook.
 
 @class AppigoPasteboard AppigoPasteboard.h
 @brief A convenience class for importing tasks and notes into Appigo Todo and Appigo Notebook.
 
 A convenience class that allows third party iPhone apps to import data into
 Appigo Applications via UIPasteboard objects.
 */

/**
 @mainpage Overview
 
 <strong>Appigo Third Party Integration</strong> is provided via a set of convenience classes by Appigo, Inc. which allow third party iPhone apps to import data into Appigo iPhone apps via persistent UIPasteboard objects.
 
 <strong>Importing Tasks into Appigo Todo:</strong>
 - <strong>Basic Tasks</strong>
 @code
 //
 // Create a new task
 //
 AppigoTask *task = [[AppigoTask alloc] initWithName:@"My Task"];
 
 //
 // Set any desired properties such as due date, priority, etc.
 //
 task.dueDate = [NSDate date]; // today
 
 //
 // Import the task into Todo
 //
 [AppigoPasteboard openTodoWithTask:task];
 
 //
 // Release the task object for good measure
 //
 [task release];
 @endcode
 
 - <strong>Projects and Checklists</strong>
 @code
 //
 // Create a new project task
 //
 AppigoTask *projectTask = [[AppigoTask alloc] initWithName:@"My Project"];
 
 //
 // Set the task type to project
 //
 [projectTask setType:AppigoTaskTypeProject withPropertyKeys:nil withPropertyValues:nil];
 
 //
 // Create and add subtasks to the project
 //
 // Note: Alternatively, you can create an NSArray of AppigoTask objects and
 // set them as subtasks of the project task by setting the subtasks property
 // of the project.
 //
 AppigoTask *subtask = [[AppigoTask alloc] initWithName:@"Subtask #1"];
 
 // ... set any desired subtask properties (not shown here)
 
 [projectTask addSubtask:subtask];
 [subtask release];
 
 subtask = [[AppigoTask alloc] initWithName:@"Subtask #2"];
 [projectTask addSubtask:subtask];
 [subtask release];
 
 //
 // Import the task into Todo
 //
 [AppigoPasteboard openTodoWithTask:projectTask];
 
 //
 // Release the project task object for good measure
 //
 [projectTask release];
 @endcode
 
 - <strong>Custom Tasks</strong>
  - See the @ref pageCustomTaskType "Custom Task Types" page for information on how you can create custom tasks to allow users of Todo to launch your application when they complete the task.
 
 <strong>Importing a basic note into Appigo Notebook:</strong>
 @code
 //
 // Create a note
 //
 AppigoNote *note = [[AppigoNote alloc] initWithName:@"My Note Title"];
 
 //
 // Set the text of the note
 //
 note.text = @"Hello world.";
 
 //
 // Import the note into Appigo Notebook.
 //
 [AppigoPasteboard openNotebookWithNote:note];
 
 //
 // Release the note for good measure.
 [note release];
 @endcode
 */

/**
 @page pageCustomTaskType Custom Task Types
 
 <strong>Appigo Todo</strong> (beginning with version 3.2) allows third party
 apps to import custom task types.
 
 <strong>What are custom task types?</strong>
 
 Custom task types in Todo allow users to perform specific actions on a task
 while viewing its detail screen. For example, Todo offers built-in task type of
 "Call a Contact." When a user specifies a contact to call, the details of a
 task then have a special phone image at the top left which, when pressed, allow
 the user to place a phone call directly from Todo to the contact specified.
 When you import a custom task type into Todo, you have the ability to specify
 an icon and custom action.
 
 The power of creating a custom task comes by using URLs which Todo will use
 when users complete tasks or perform their action. The
 setActionForTaskWithAppDisplayName: method in the AppigoTask class allows you
 to specify your app's display name, a series of URLs and an image that will be
 displayed in Todo when a user views the task.
 
 For means of illustration, we'll show an example of how Appigo's AccuFuel
 (a fuel economy tracking app) might use this to set up a reminder task to
 change the oil in a vehicle.
 
 @code
 
 //
 // Create a new task
 //
 AppigoTask *task = [[AppigoTask alloc] initWithName:@"Jeep Liberty: Change Oil"];
 
 //
 // Set the due date to be due in 5 days from today
 //
 NSCalendar *calendar = [NSCalendar currentCalendar];
 NSDate *today = [NSDate date];
 
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setDay:5];
 
 NSDate *inFiveDays = [calendar dateByAddingComponents:components toDate:today options:0];
 task.dueDate = inFiveDays;
 [components release];
 
 //
 // These are the custom URLs that we want Todo to use when opening our
 // app. We will pass a reminder of "123" to Todo so that when the user
 // completes the task or performs the action on the task, AccuFuel will
 // be able to identify which reminder Todo is referring to.
 //
 NSURL *completionLaunchURL = [NSURL URLWithString:@"accufuel://com.appigo.todo.customtask/?method=task-completed&reminder-id=123"];
 NSURL *actionLaunchURL = [NSURL URLWithString:@"accufuel://com.appigo.todo.customtask/?method=task-action&reminder-id=123"];
 
 //
 // Prepare the custom action image that Todo will display as a button
 // to the left of the task name when the user views the task. When the
 // user taps this button, the actionLaunchURL will be called. As
 // mentioned in the API documentation, this action image MUST be 29x29
 // pixels and MUST be in PNG format. Other sizes and types will be
 // ignored.
 //
 UIImage *actionImage = [UIImage imageNamed:@"accufuel-todo-action-image.png"];
 
 //
 // Set up the custom task
 //
 [task setActionForTaskWithAppDisplayName:@"AccuFuel"
 withCompletionNotifyURL:nil
 withCompletionLaunchURL:completionLaunchURL
 withActionLaunchURL:actionLaunchURL
 withActionImage:actionImage];
 
 //
 // Import this task into Todo
 //
 [AppigoPasteboard openTodoWithTask:task];
 [task release];
 
 @endcode
 
 */

/**
 @page pageTaskTypeData Task Type Data
 
 <strong>Appigo Todo</strong> stores corresponding task type data (phone
 numbers, addresses, email addresses, etc.) with a task. Todo also supports
 synchronizing this data with third party task management services via use of
 special identifiers in a task's note.
 
 The AppigoTask class provides a convenience method
 (setType:withPropertyKeys:WithPropertyValues:) to simplify the process of
 specifying this task type data.
 
 Task Type Data (keys and values) is used for the following task types:
 - AppigoTaskTypeCallContact
 - AppigoTaskTypeSMSContact
 - AppigoTaskTypeEmailContact
 - AppigoTaskTypeVisitLocation
 - AppigoTaskTypeURL
 
 If keys and values are specified on any other task type, it will be ignored.
 
 <strong>Task Type Data Keys</strong>
 
 The property keys are meant to specify label items such as
 <strong>mobile</strong>, <strong>home</strong>, <strong>url</strong>, etc.
 These labels are shown to the user on the left side of a button in a
 UIActionSheet when the user taps the task's action button.
 
 <strong>Task Type Data Values</strong>
 
 The property values must correspond to the specified property keys and are the
 values of the labels. They should be phone numbers, email addresses, street
 addresses, etc.
 
 <strong>Example:</strong> Creating a Call a Contact Task
 
 @code
 
 AppigoTask *task = [[AppigoTask alloc] initWithName:@"Call Bob Smith"];
 task.dueDate = [NSDate date]; // today
 [task setType:AppigoTaskTypeCallContact
	withPropertyKeys:[NSArray arrayWithObjects:@"mobile", @"home", @"work", nil]
  withPropertyValues:[NSArray arrayWithObjects:@"555-555-1111", @"555-555-2222", @"555-555-3333", nil]];
 
 [AppigoPasteboard openTodoWithTask:task];
 [task release];
 
 @endcode
 
 */

#import <UIKit/UIKit.h>

@class AppigoTask;
@class AppigoNote;


#pragma mark -
#pragma mark General Constants

// iTunes App Store URLs for Appigo's Apps
#ifdef IPAD
#define kAppigoTodoAppStoreURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=371787147&mt=8"
#else
#define kAppigoTodoAppStoreURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=282778557&mt=8"
#endif

#define kAppigoNotebookAppStoreURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290089621&mt=8"



#pragma mark -
@interface AppigoPasteboard : NSObject <UIAlertViewDelegate>
{
}


#pragma mark -
#pragma mark Task Methods


/**
 Check to see if Appigo Todo is installed.
 
 @return Returns YES if Appigo Todo is installed (calls UIApplication's canOpenURL:@"appigotodo://")
 */
+ (BOOL)isTodoInstalled;

/**
 Check to see if Appigo Todo is installed and has support for @2x graphics.
 This call checks for a specific "versioned" URL Scheme that Todo includes in
 versions new enough for @2x graphics support.  If your code can run on a
 retina display device, you should call this method first before attempting to
 send a hi-res (@2x) custom action icon to Todo.
 
 @return Returns YES if Appigo Todo is installed (calls UIApplication's canOpenURL:@"appigotodov2://")
 */
+ (BOOL)isTodoInstalledWith2xSupport;

/**
 Set the Appigo Pasteboard task.
 
 @param task The task to set/add to the Appigo Pasteboard to make it available to other applications.
 */
+ (void)setTask:(AppigoTask *)task;

/**
 Get the currently available task from the Appigo Pasteboard.
 
 @return Returns the currently available task from the pasteboard or nil if no task is currently present.
 */
+ (AppigoTask *)task;

/**
 Get the currently available task from a specific pasteboard.
 
 @param pasteboardName The name of the specific pasteboard to look for a task.
 @return Returns the currently available task from the specified pasteboard or nil if no task is available on the specified pasteboard.
 */
+ (AppigoTask *)taskFromPasteboardNamed:(NSString *)pasteboardName;

/**
 Launch Appigo Todo and import the specified task.
 
 @param task The task to import into Appigo Todo.
 @return Returns NO if Todo was unable to be launched. Check the console log for the specific reason. In most cases, the user likely does not have Appigo Todo (or Appigo Todo Lite) installed. We recommend using a UIAlertView to prompt the user about this (and offer a direct link to the App Store for them to download/purchase Notebook). Samples of how to do this are available in CustomTask (a sample third party app which demonstrates how to use Appigo's Third Party Integration).
 */
+ (BOOL)openTodoWithTask:(AppigoTask *)task;


#pragma mark -
#pragma mark Note Methods

/**
 Set the Appigo Pasteboard note.
 
 @param note The note to set/add to the Appigo Pasteboard to make it available to other applications.
 */
+ (void)setNote:(AppigoNote *)note;

/**
 Get the currently available note from the Appigo Pasteboard.
 
 @return Returns the currently available note from the pasteboard or nil if no note is currently present.
 */
+ (AppigoNote *)note;

/**
 Get the currently available note from a specific pasteboard.
 
 @param pasteboardName The name of the specific pasteboard to look for a note.
 @return Returns the currently available note from the specified pasteboard or nil if no note is available on the specified pasteboard.
 */
+ (AppigoNote *)noteFromPasteboardNamed:(NSString *)pasteboardName;

/**
 Launch Appigo Notebook and import the specified note.
 
 @param note The note to import into Appigo Notebook.
 @return Returns NO if Notebook was unable to be launched. Check the console log for the specific reason. In most cases, the user likely does not have Appigo Notebook installed. We recommend using a UIAlertView to prompt the user about this (and offer a direct link to the App Store for them to download/purchase Notebook). Samples of how to do this are available in CustomTask (a sample third party app which demonstrates how to use Appigo's Third Party Integration).
 */
+ (BOOL)openNotebookWithNote:(AppigoNote *)note;


#pragma mark -
#pragma mark Global Settings

/**
 Specify whether the AppigoPasteboard should automatically handle showing an
 alert if the user does not already have the target Appigo app installed when
 calling openTodoWithTask: or openNotebookWithNote:.
 
 @param showAlertsAutomatically A BOOL value to specify whether to show alerts.
 By default, this is set to YES. Specify NO to handle informing users yourself.
 */
+ (void)setShowErrorAlertsAutomatically:(BOOL)showAlertsAutomatically;


@end
