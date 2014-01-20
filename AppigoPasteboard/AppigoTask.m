/**
 
 Appigo Third Party Integration - AppigoTask.m
 
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


#pragma mark Task Properties


#define kAppigoTaskNameKey				@"com.appigo.task.name"					// NSString *
#define kAppigoTaskTypeKey				@"com.appigo.task.type"					// NSNumber * (int)
#define kAppigoTaskTypeKeysKey			@"com.appigo.task.type.keys"			// NSArray * of NSString *
#define kAppigoTaskTypeValuesKey		@"com.appigo.task.type.values"			// NSArray * of NSString *
#define kAppigoTaskPriorityKey			@"com.appigo.task.priority"				// NSNumber * (int)
#define kAppigoTaskDueDateKey			@"com.appigo.task.due-date"				// NSDate *
#define kAppigoTaskDueDateHasTimeKey	@"com.appigo.task.due-date-has-time"	// NSNumber * (BOOL)
#define kAppigoTaskStartDateKey			@"com.appigo.task.start-date"			// NSDate *
#define kAppigoTaskCompletionDateKey	@"com.appigo.task.completion-date"		// NSDate *
#define kAppigoTaskRepeatKey			@"com.appigo.task.repeat"				// NSNumber * (int)
#define kAppigoTaskAdvancedRepeatKey	@"com.appigo.task.advanced-repeat"		// NSString *
#define kAppigoTaskNoteKey				@"com.appigo.task.note"					// NSString *
#define kAppigoTaskListKey				@"com.appigo.task.list"					// NSString *
#define kAppigoTaskContextKey			@"com.appigo.task.context"				// NSString *
#define kAppigoTaskTagsKey				@"com.appigo.task.tags"					// NSArray * (of NSString *)
#define kAppigoTaskActionImageDataKey	@"com.appigo.task.action-image-data"	// NSData * (PNG data representation of UIImage)
#define kAppigoTaskSubtasksKey			@"com.appigo.task.subtasks"				// NSArray * (of NSDictionary * tasks)


#pragma mark -
@implementation AppigoTask


@synthesize name;
@synthesize type;
@synthesize typeKeys;
@synthesize typeValues;
@synthesize priority;
@synthesize dueDate;
@synthesize dueDateHasTime;
@synthesize startDate;
@synthesize completionDate;
@synthesize repeat;
@synthesize advancedRepeat;
@synthesize note;
@synthesize list;
@synthesize context;
@synthesize tags;
@synthesize actionImage;


#pragma mark -
- (id)init
{
	if (self = [self initWithName:@"Unknown"])
	{
	}
	
	return self;
}


- (id)initWithName:(NSString *)taskName
{
	if (self = [super init])
	{
		if ( (taskName == nil) || ([[taskName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) )
			name = [[NSString alloc] initWithString:@"Unknown"];
		else
			name = [[NSString alloc] initWithString:[taskName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		
		_subtasks = [[NSMutableArray alloc] init];
		
		type = AppigoTaskTypeNormal;
		priority = AppigoTaskPriorityNone;
		dueDateHasTime = NO;
		repeat = 0;
	}
	
	return self;
}


- (void)dealloc
{
	[name release];
	[typeKeys release];
	[typeValues release];
	[dueDate release];
	[startDate release];
	[completionDate release];
	[advancedRepeat release];
	[note release];
	[list release];
	[context release];
	[tags release];
	[actionImage release];
	
	[_subtasks release];
	
	[super dealloc];
}


- (void)setType:(AppigoTaskType)aTaskType withPropertyKeys:(NSArray *)keys withPropertyValues:(NSArray *)values
{
	// Check to make sure that the type is being set properly.  If being set to
	// normal, project, or checklist, ignore the keys and values entirely.
	
	if ( (aTaskType == AppigoTaskTypeNormal)
		|| (aTaskType == AppigoTaskTypeProject)
		|| (aTaskType == AppigoTaskTypeChecklist) )
	{
		type = aTaskType;
		
		// Clear out old keys/values if they exist
		if (typeKeys != nil)
		{
			[typeKeys release];
			typeKeys = nil;
		}
		
		if (typeValues != nil)
		{
			[typeValues release];
			typeValues = nil;
		}
		
		return;
	}
	
	// If this is reached, the keys and values are required (have at least one
	// value) and have matching number of items that are all NSString objects.
	if ( (keys == nil) || (values == nil) )
	{
		// Set the task to normal type and return without doing anything else
		type = AppigoTaskTypeNormal;
		return;
	}
	
	type = aTaskType;
	
	int numOfKeys = [keys count];
	int numOfValues = [values count];
	
	if ( (numOfKeys == 0) || (numOfValues == 0) || (numOfKeys != numOfValues) )
	{
		type = AppigoTaskTypeNormal;
		return;
	}
	
	// Assume that the keys and values are actually NSStrings and store them
	if (typeKeys != nil)
		[typeKeys release];
	typeKeys = [[NSArray alloc] initWithArray:keys];
	
	if (typeValues != nil)
		[typeValues release];
	typeValues = [[NSArray alloc] initWithArray:values];
}


- (void)addSubtask:(AppigoTask *)subtask
{
	if (subtask != nil)
		[_subtasks addObject:subtask];
}


- (void)setActionForTaskWithAppDisplayName:(NSString *)aDisplayName
				   withCompletionNotifyURL:(NSURL *)aCompletionNotifyURL
				   withCompletionLaunchURL:(NSURL *)aCompletionLaunchURL
					   withActionLaunchURL:(NSURL *)anActionLaunchURL
						   withActionImage:(UIImage *)anActionImage
{
	// Must have a non-empty display name
	if ( (aDisplayName == nil) || ([[aDisplayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) )
	{
		NSLog(@"displayName must not be nil or empty.");
		return;
	}
	
	// Must have at least one URL specified
	if ( (aCompletionNotifyURL == nil) && (aCompletionLaunchURL == nil)
		&& (anActionLaunchURL == nil) )
	{
		NSLog(@"Must specify at least one of: completionNotifyURL, completionLaunchURL, actionLaunchURL");
		return;
	}
	
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	
	// App ID
	[keys addObject:kAppigoTaskTypeAppIdKey];
	[values addObject:[[NSBundle mainBundle] bundleIdentifier]];
	
	// Display Name
	[keys addObject:kAppigoTaskTypeDisplayNameKey];
	[values addObject:aDisplayName];
	
	// Completion Notify URL
	if (aCompletionNotifyURL != nil)
	{
		[keys addObject:kAppigoTaskTypeCompletionNotifyUrlKey];
		[values addObject:[aCompletionNotifyURL absoluteString]];
	}
	
	// Completion Launch URL
	if (aCompletionLaunchURL != nil)
	{
		[keys addObject:kAppigoTaskTypeCompletionLaunchUrlKey];
		[values addObject:[aCompletionLaunchURL absoluteString]];
	}
	
	// Action Launch URL
	if (anActionLaunchURL != nil)
	{
		[keys addObject:kAppigoTaskTypeActionLaunchURLKey];
		[values addObject:[anActionLaunchURL absoluteString]];
	}
	
	// Set the custom task type
	[self setType:AppigoTaskTypeCustom withPropertyKeys:keys withPropertyValues:values];
	[keys release];
	[values release];
	
	// Add in the action image only if there's an actionLaunchURL
	if (anActionImage != nil)
	{
		if (anActionLaunchURL == nil)
		{
			NSLog(@"The actionImage will not be used because there is no actionLaunchURL specified");
		}
		else
		{
			// Make sure that the action image is the proper size
			BOOL allowTheImage = NO;
			
			// Check to see if Todo with @2x graphics support is installed
			BOOL v2Supported = [AppigoPasteboard isTodoInstalledWith2xSupport];
			
			if (v2Supported == YES)
			{
				// Allow both 58x58px and 29x29px images
				if ( ( (anActionImage.size.width == 29) && (anActionImage.size.height == 29) )
					|| ( (anActionImage.size.width == 58) && (anActionImage.size.height == 58) ) )
				{
					allowTheImage = YES;
				}
			}
			else
			{
				// Only allow 29x29px images
				if ( (anActionImage.size.width == 29) && (anActionImage.size.height == 29) )
				{
					allowTheImage = YES;
				}
			}
			
			if (allowTheImage == NO)
			{
				NSLog(@"The actionImage will not be used because it is not the right size.");
			}
			else
			{
				// Make sure that we can get a PNG representation of the UIImage
				NSData *imageData = UIImagePNGRepresentation(anActionImage);
				if (imageData != nil)
					self.actionImage = anActionImage;
				else
					NSLog(@"The actionImage will not be used because UIImagePNGRepresentation(actionImage) returns nil.");
			}
		}
	}
}


- (NSString *)plainTextRepresentationWithName:(BOOL)includeName
{
	NSMutableString *text = [[[NSMutableString alloc] init] autorelease];
	
	if (includeName == YES)
		[text appendFormat:@"%@\n\n", self.name];
	
	// Priority
	NSString *taskPriorityString;
	switch (self.priority)
	{
		case AppigoTaskPriorityHigh:
			taskPriorityString = NSLocalizedString(@"High", @"High task priority");
			break;
		case AppigoTaskPriorityMedium:
			taskPriorityString = NSLocalizedString(@"Medium", @"Medium task priority");
			break;
		case AppigoTaskPriorityLow:
			taskPriorityString = NSLocalizedString(@"Low", @"Low task priority");
			break;
		default:
			taskPriorityString = NSLocalizedString(@"None", @"No priority");
			break;
	}
	
	[text appendFormat:@"%@: %@\n", NSLocalizedString(@"Priority", @""), taskPriorityString];
	
	// Due Date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	if (self.dueDate != nil)
	{
		[text appendFormat:@"%@: ", NSLocalizedString(@"Due Date", @"")];
		if ([self.dueDate compare:[NSDate distantFuture]] == NSOrderedSame)
			[text appendFormat:@"%@\n", NSLocalizedString(@"No due date", @"")];
		else
			[text appendFormat:@"%@\n", [dateFormatter stringFromDate:dueDate]];
	}
	
	// Start Date
	if ( (self.startDate != nil) && ([self.startDate compare:[NSDate distantPast]] != NSOrderedSame) )
	{
		[text appendFormat:@"%@: %@\n",
		 NSLocalizedString(@"Start Date", @""),
		 [dateFormatter stringFromDate:self.startDate]];
	}
	
	// Completed
	if ( (self.completionDate == nil) || ([self.completionDate compare:[NSDate distantPast]] == NSOrderedSame) )
		[text appendFormat:@"%@: %@\n", NSLocalizedString(@"Completed", @""), NSLocalizedString(@"No", @"")];
	else
		[text appendFormat:@"%@: %@\n", NSLocalizedString(@"Completed", @""), [dateFormatter stringFromDate:self.completionDate]];
	
	// Note
	if (self.note != nil)
	{
		[text appendFormat:@"%@:\n%@\n", NSLocalizedString(@"Note", @""), self.note];
	}
	
	// Subtasks
	for (int i = 0; i < [_subtasks count]; i++)
	{
		AppigoTask *subtask = [_subtasks objectAtIndex:i];
		
		[text appendString:@"\n--------\n\n"];
		[text appendString:[subtask plainTextRepresentationWithName:YES]];
	}
								
	[dateFormatter release];
	
	return text;
}


- (AppigoNote *)noteRepresentation
{
	AppigoNote *newNote = [[[AppigoNote alloc] initWithName:self.name] autorelease];
	
	NSMutableString *noteText = [[NSMutableString alloc] init];
	
	[noteText appendString:[self plainTextRepresentationWithName:NO]];
	
	newNote.text = noteText;
	[noteText release];
	
	return newNote;
}


#pragma mark -
#pragma mark NSCoding Implementation


- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
		
		NSString *aName = [aDecoder decodeObjectForKey:kAppigoTaskNameKey];
		if (aName == nil)
			name = [[NSString alloc] initWithString:@"Unknown"];
		else
			name = [[NSString alloc] initWithString:[aName stringByTrimmingCharactersInSet:whitespace]];
		
		type = (AppigoTaskType)[aDecoder decodeIntegerForKey:kAppigoTaskTypeKey];
		
		NSArray *keys = [aDecoder decodeObjectForKey:kAppigoTaskTypeKeysKey];
		if (keys != nil)
			typeKeys = [[NSArray alloc] initWithArray:keys];
		
		NSArray *values = [aDecoder decodeObjectForKey:kAppigoTaskTypeValuesKey];
		if (values != nil)
			typeValues = [[NSArray alloc] initWithArray:values];
		
		int pri = [aDecoder decodeIntegerForKey:kAppigoTaskPriorityKey];
		switch (pri) {
			case 1:
				priority = AppigoTaskPriorityHigh;
				break;
			case 2:
				priority = AppigoTaskPriorityMedium;
				break;
			case 3:
				priority = AppigoTaskPriorityLow;
				break;
			case 4:
				priority = AppigoTaskPriorityNone;
				break;
		}

		NSDate *aDueDate = [aDecoder decodeObjectForKey:kAppigoTaskDueDateKey];
		if (aDueDate != nil)
			dueDate = [aDueDate retain];
		
		dueDateHasTime = [aDecoder decodeBoolForKey:kAppigoTaskDueDateHasTimeKey];
		
		NSDate *aStartDate = [aDecoder decodeObjectForKey:kAppigoTaskStartDateKey];
		if (aStartDate != nil)
			startDate = [aStartDate retain];
		
		NSDate *aCompletionDate = [aDecoder decodeObjectForKey:kAppigoTaskCompletionDateKey];
		if (aCompletionDate != nil)
			completionDate = [aCompletionDate retain];
		
		repeat = [aDecoder decodeIntegerForKey:kAppigoTaskRepeatKey];
		
		NSString *anAdvancedRepeat = [aDecoder decodeObjectForKey:kAppigoTaskAdvancedRepeatKey];
		if (anAdvancedRepeat != nil)
			advancedRepeat = [[NSString alloc] initWithString:[anAdvancedRepeat stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *aNote = [aDecoder decodeObjectForKey:kAppigoTaskNoteKey];
		if (aNote != nil)
			note = [[NSString alloc] initWithString:[aNote stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *aList = [aDecoder decodeObjectForKey:kAppigoTaskListKey];
		if (aList != nil)
			list = [[NSString alloc] initWithString:[aList stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *aContext = [aDecoder decodeObjectForKey:kAppigoTaskContextKey];
		if (aContext != nil)
			context = [[NSString alloc] initWithString:[aContext stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *someTags = [aDecoder decodeObjectForKey:kAppigoTaskTagsKey];
		if (someTags != nil)
			tags = [[NSString alloc] initWithString:[someTags stringByTrimmingCharactersInSet:whitespace]];
		
		NSData *imageData = [aDecoder decodeObjectForKey:kAppigoTaskActionImageDataKey];
		if (imageData != nil)
			actionImage = [[UIImage alloc] initWithData:imageData];
		
		// Now check for subtasks
		NSArray *someSubtasks = [aDecoder decodeObjectForKey:kAppigoTaskSubtasksKey];
		if (someSubtasks != nil)
			_subtasks = [[NSMutableArray alloc] initWithArray:someSubtasks];
		else
			_subtasks = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:kAppigoTaskNameKey];
	
	[aCoder encodeInteger:type forKey:kAppigoTaskTypeKey];
	
	if (typeKeys != nil)
		[aCoder encodeObject:typeKeys forKey:kAppigoTaskTypeKeysKey];
	
	if (typeValues != nil)
		[aCoder encodeObject:typeValues forKey:kAppigoTaskTypeValuesKey];
	
	[aCoder encodeInteger:priority forKey:kAppigoTaskPriorityKey];
	
	if (dueDate != nil)
		[aCoder encodeObject:dueDate forKey:kAppigoTaskDueDateKey];
	
	[aCoder encodeBool:dueDateHasTime forKey:kAppigoTaskDueDateHasTimeKey];
	
	if (startDate != nil)
		[aCoder encodeObject:startDate forKey:kAppigoTaskStartDateKey];
	
	if (completionDate != nil)
		[aCoder encodeObject:completionDate forKey:kAppigoTaskCompletionDateKey];
	
	[aCoder encodeInteger:repeat forKey:kAppigoTaskRepeatKey];
	
	if (advancedRepeat != nil)
		[aCoder encodeObject:advancedRepeat forKey:kAppigoTaskAdvancedRepeatKey];
	
	if (note != nil)
		[aCoder encodeObject:note forKey:kAppigoTaskNoteKey];
	
	if (list != nil)
		[aCoder encodeObject:list forKey:kAppigoTaskContextKey];
	
	if (context != nil)
		[aCoder encodeObject:context forKey:kAppigoTaskTagsKey];
	
	if (tags != nil)
		[aCoder encodeObject:tags forKey:kAppigoTaskSubtasksKey];
	
	if (actionImage != nil)
	{
		// Make sure that the image can be converted to PNG data
		NSData *imageData = UIImagePNGRepresentation(actionImage);
		if (imageData != nil)
			[aCoder encodeObject:imageData forKey:kAppigoTaskActionImageDataKey];
	}
	
	if ([_subtasks count] > 0)
		[aCoder encodeObject:_subtasks forKey:kAppigoTaskSubtasksKey];
}


#pragma mark -
#pragma mark Custom Properties


- (NSArray *)subtasks
{
	return _subtasks;
}


- (void)setSubtasks:(NSArray *)newSubtasks
{
	// Clear out all the old subtasks since the user is specifying a new set
	if (newSubtasks == nil)
	{
		[_subtasks removeAllObjects];
		return;
	}
	
	[_subtasks release];
	_subtasks = [[NSMutableArray alloc] initWithArray:newSubtasks];
}


@end
