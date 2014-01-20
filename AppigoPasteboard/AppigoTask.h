/**
 
 Appigo Third Party Integration - AppigoTask.h
 
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
 @file AppigoTask.h
 @brief A class for representing an importable task.
 
 @class AppigoTask AppigoNote.h
 @brief A class for representing an importable task.
 
 A class to represent a task that can be placed on the Appigo Pasteboard and
 referenced by Appigo Applications.
 */


#import <Foundation/Foundation.h>


@class AppigoNote;


#define kAppigoTaskTypeAppIdKey					@"app-id"
#define kAppigoTaskTypeDisplayNameKey			@"app-display-name"
#define kAppigoTaskTypeCompletionNotifyUrlKey	@"completion-notify-url"
#define kAppigoTaskTypeCompletionLaunchUrlKey	@"completion-launch-url"
#define kAppigoTaskTypeActionLaunchURLKey		@"action-launch-url"


#pragma mark -
#pragma mark Enums


/**
 An enumeration of task priorities.
 */
typedef enum
{
	AppigoTaskPriorityHigh = 1,
	AppigoTaskPriorityMedium,
	AppigoTaskPriorityLow,
	AppigoTaskPriorityNone
} AppigoTaskPriority;


/**
 An enumeration of task types.
 */
typedef enum
{
	AppigoTaskTypeNormal = 0,
	AppigoTaskTypeProject,
	AppigoTaskTypeCallContact,
	AppigoTaskTypeSMSContact,
	AppigoTaskTypeEmailContact,
	AppigoTaskTypeVisitLocation,
	AppigoTaskTypeURL,
	AppigoTaskTypeChecklist,
	AppigoTaskTypeCustom // used for custom actions, see setActionForTask:
} AppigoTaskType;


#pragma mark -
@interface AppigoTask : NSObject <NSCoding>
{
	NSString			*name;
	AppigoTaskType		type;
	NSArray				*typeKeys;
	NSArray				*typeValues;
	AppigoTaskPriority	priority;
	NSDate				*dueDate;
	BOOL				dueDateHasTime;
	NSDate				*startDate;
	NSDate				*completionDate;
	NSInteger			repeat;
	NSString			*advancedRepeat;
	NSString			*note;
	NSString			*list;
	NSString			*context;
	NSString			*tags;
	UIImage				*actionImage;
	
	NSMutableArray		*_subtasks;
}


#pragma mark -
#pragma mark Properties

/** The name of the task. */
@property (nonatomic, readonly)	NSString			*name;

/**
 The task type. If left unspecified, AppigoTaskTypeNormal will be used.
 */

@property (nonatomic, readonly)	AppigoTaskType		type;

/**
 An array of keys (NSString *) with accompanying typeValues which specify
 additional type data information such as phone numbers, addresses, etc. which
 correspond to the task type.
 */
@property (nonatomic, readonly) NSArray				*typeKeys;

/** An array of values (NSString *) corresponding to the typeKeys. */
@property (nonatomic, readonly) NSArray				*typeValues;

/** An AppigoTaskPriority value to determine how important the task is. */
@property (nonatomic, assign)	AppigoTaskPriority	priority;

/**
 An NSDate specifying when the task is due.  If you leave this nil, you are
 specifying that the task should not have a due date.
 */
@property (nonatomic, retain)	NSDate				*dueDate;

/**
 Specify YES when the dueDate contains specific information about the time that
 the task is due.
 */
@property (nonatomic, assign)	BOOL				dueDateHasTime;

/**
 An NSDate specifying when work for this task should begin to occur.
 This field is meant for compatibility with some synchronization options
 and may/may not be shown in the user interface in an Appigo application.
 */
@property (nonatomic, retain)	NSDate				*startDate;

/**
 An NSDate specifying when the task was completed.  If the task is active
 and not completed, this should be left nil.
 */
@property (nonatomic, retain)	NSDate				*completionDate;

/**
 An integer value indicating whether the task should repeat.  Specify
 0 to indicate that the task does not repeat.  Other allowed values are:
 
 Repeat from Due Date
 - 1  - Weekly
 - 2  - Monthly
 - 3  - Yearly
 - 4  - Daily
 - 5  - Bi-weekly
 - 6  - Bi-monthly
 - 7  - Semi-annually
 - 8  - Quarterly
 - 9  - Repeat with Parent
 - 50 - Advanced (look for additional information in the advanced repeat parameter)
 
 Repeat from Completion Date
 - 101 - Weekly
 - 102 - Monthly
 - 103 - Yearly
 - 104 - Daily
 - 105 - Bi-weekly
 - 106 - Bi-monthly
 - 107 - Semi-annually
 - 108 - Quarterly
 - 109 - Repeat with Parent
 - 150 - Advanced (look for additional information in the advanced repeat parameter)
 */
@property (nonatomic, assign)	NSInteger			repeat;

/**
 A string which contains advance repeat information.
 
 Valid strings should conform to one of the following formats:
 - Every X <days, weeks, months, years>
 - Every <Monday, Tuesday...Sunday, Weekday, Weekend>
 - On the X <Monday...Sunday> of the month
 */
@property (nonatomic, retain)	NSString			*advancedRepeat;

/**
 A string of supporting information about the task.
 */
@property (nonatomic, retain)	NSString			*note;

/**
 A case-insensitive list name that the task belongs to.  If a matching
 list is found in Todo the task will be placed inside the corresponding
 list.  If multiple lists with the same name exist in Todo, the list
 used for this task is undefined.  If a matching list name is not found
 in Todo, the list will be created before assigning the task to the list.
 */
@property (nonatomic, retain)	NSString			*list;

/**
 A case-insensitive context name that the task should be associated with.
 If a matching context is found in Todo, the context will be used.  If no
 existing context is found, the specified context will be created.
 */
@property (nonatomic, retain)	NSString			*context;

/**
 A comma-separated list of tags to associate with the task.  Non-existing
 tags will be created.
 */
@property (nonatomic, retain)	NSString			*tags;

/**
 The action image associated with a custom task type. See the
 @ref pageCustomTaskType "Custom Task Types" page for more information.
 */
@property (nonatomic, retain)	UIImage				*actionImage;

/**
 An array of tasks that are the subtasks of a project or checklist type.  If
 the task type is not set as Project/Checklist, any specified subtasks will be
 discarded when imported to Todo.
 */
@property (nonatomic, copy)		NSArray				*subtasks;


#pragma mark -
#pragma mark Methods


/**
 Initialize a new task object.
 
 @param taskName The task name. The name will be trimmed of whitespace (an
 empty name is invalid and will be replaced with, "Unknown").
 */
- (id)initWithName:(NSString *)taskName;


/**
 Set the task type.
 
 All task types except for Normal, Project, and Checklist must have
 corresponding keys and values set for additional task type information. This
 information will eventually be used to present phone numbers to a user such as
 "mobile: 555-555-1234" for a Call a Contact task type. The keys and values will
 be ignored when setting task types of AppigoTaskTypeNormal,
 AppigoTaskTypeProject, and AppigoTaskTypeChecklist.
 
 For more information about task type data (the property keys and values, refer
 to the @ref pageTaskTypeData "Task Type Data" page.
 
 @param aTaskType The new task type.
 @param keys An array of keys (NSString *) that match up with the number of
 values. These keys specify additional task type information such as phone
 numbers, addresses, urls, etc. that will be shown to the user when they tap
 a task's action button in Todo (to call a contact, visit a website, etc.).
 @param values An array of values which match up with the number of keys. The
 values will be items such as phone numbers, email addresses, addresses, etc.
 */
- (void)setType:(AppigoTaskType)aTaskType withPropertyKeys:(NSArray *)keys withPropertyValues:(NSArray *)values;

/**
 A convenience method to add a subtask to the task. You should only add subtasks
 to projects or checklists. Subtasks added to other types of tasks will be
 ignored by Todo if you attempt to import them.
 
 @param subtask The subtask to add.
 */
- (void)addSubtask:(AppigoTask *)subtask;


/**
 Add a custom action to the task which will allow custom actions on the task
 once it is imported into Appigo Todo.  An overview of this process is described
 on the @ref pageCustomTaskType "Custom Task Types" page.
 
 Set an option action that will be used when importing a task in Todo.  This
 allows third party applications to be notified/called when the user completes
 the task or when they perform the task type's "action" (just like calling a
 contact on the Call Contact task).  You must specify at least one of the URLs
 in the parameters.  If you do not specify any URLs, this call will do nothing.

 Be aware that custom task information (name, URLs, etc.) is stored in the
 task's typeData and the existing type and typeData information will be
 replaced with the information in this method.

 @note Calling this method multiple times on the same task will replace the
 previously set action.

 @param aDisplayName (required) A string that will be used to show the origin
 of the custom task in Todo. This string is used regardless of the device's
 language/locale/region settings.
 
 @param aCompletionNotifyURL (optional) A URL which specifies a call to a backend
 service you may operate.  If specified, a UIAlertView will ask the user if they
 want to notify	appDisplayName that they are completing the task.  This URL
 should reference a service available on the Internet and not your iPhone app
 (use completionLaunchURL to launch your application when a task is completed).
 
 @param aCompletionLaunchURL (optional) A URL which can be used to launch your
 iPhone app when a user completes the task.  A UIAlertView will ask the user if
 they want to launch appDisplayName.
 
 @param anActionLaunchURL (optional) A URL which will be used to perform an action
 from the task's detail screen.  A UIAlertView will ask the user if they want to
 open appDisplayName before calling openURL: on this URL.
 
 @param anActionImage (optional) This image will be used on the task's detail
 screen to the left of the task's name and should be drawn to mimic Todo's
 built-in action buttons, which are typically round and should appear to look
 like a button.  For an example of this, create a "Call a Contact" task and then
 look at the icon which appears to the left of the task name.
 The size of this image must be 29x29 pixels (or 58x58px on retina-display
 devices) pixels and should be drawn using a transparent background.  The image
 will be transferred to Todo as NSData * using UIImagePNGRepresentation().  If
 UIImagePNGRepresentation() returns nil, a default action image will be
 used. Action Images are tied to a specific application ID.  If you specify a
 different image than previous imports, the most recently imported image
 will be used for all previous imported tasks made from your application.
 actionLaunchURL must also be specified if you specify this image.  If
 actionLaunchURL is nil, the actionImage will be ignored.  If you are running on
 iOS 4 or newer, you can use the following to test whether your app is running
 on a hi-res device: if ([[UIScreen mainScreen] scale] > 1) ...
 
 */
- (void)setActionForTaskWithAppDisplayName:(NSString *)aDisplayName
				   withCompletionNotifyURL:(NSURL *)aCompletionNotifyURL
				   withCompletionLaunchURL:(NSURL *)aCompletionLaunchURL
					   withActionLaunchURL:(NSURL *)anActionLaunchURL
						   withActionImage:(UIImage *)anActionImage;


/**
 Get a plain text representation of a task.
 
 @param includeName Specify YES to include the name in the text representation
 or NO to omit it.
 @return Returns a plain text representation of the task.
 */
- (NSString *)plainTextRepresentationWithName:(BOOL)includeName;


/**
 Build an AppigoNote object from the task that can be used to import the task
 into Appigo Notebook.
 
 @return Returns an AppigoNote object.
 */
- (AppigoNote *)noteRepresentation;

@end
