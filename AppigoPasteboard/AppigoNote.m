/**
 
 Appigo Third Party Integration - AppigoNote.m
 
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

#import "AppigoNote.h"

#import "AppigoTask.h"


#pragma mark Note Properties


#define kAppigoNoteNameKey				@"com.appigo.note.name"					// NSString *
#define kAppigoNoteTextKey				@"com.appigo.note.text"					// NSString *
#define kAppigoNoteNotebookKey			@"com.appigo.note.notebook"				// NSString *


#pragma mark -
@implementation AppigoNote


@synthesize name;
@synthesize text;
@synthesize notebook;


#pragma mark -
- (id)init
{
	if (self = [self initWithName:@"Unknown"])
	{
	}
	
	return self;
}


- (id)initWithName:(NSString *)noteName
{
	if (self = [super init])
	{
		if ( (noteName == nil) || ([[noteName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) )
			name = [[NSString alloc] initWithString:@"Unknown"];
		else
			name = [[NSString alloc] initWithString:[noteName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	}
	
	return self;
}


- (void)dealloc
{
	[name release];
	[text release];
	[notebook release];
	
    [super dealloc];
}


- (NSString *)plainTextRepresentationWithName:(BOOL)includeName
{
	NSMutableString *noteString = [[[NSMutableString alloc] init] autorelease];
	
	// Name
	if (includeName == YES)
	{
		[noteString appendString:self.name];
		[noteString appendString:@"\n\n"];
	}
	
	// Text
	if (self.text != nil)
	{
		[noteString appendString:self.text];
	}
	
	return noteString;
}


- (AppigoTask *)taskRepresentation
{
	AppigoTask *aTask = [[[AppigoTask alloc] initWithName:self.name] autorelease];
	
	aTask.note = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	aTask.list = self.notebook;
	
	return aTask;
}


#pragma mark -
#pragma mark NSCoding Implementation


- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
		
		NSString *aName = [aDecoder decodeObjectForKey:kAppigoNoteNameKey];
		if (aName == nil)
			name = [[NSString alloc] initWithString:@"Unknown"];
		else
			name = [[NSString alloc] initWithString:[aName stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *aText = [aDecoder decodeObjectForKey:kAppigoNoteTextKey];
		if (aText != nil)
			text = [[NSString alloc] initWithString:[aText stringByTrimmingCharactersInSet:whitespace]];
		
		NSString *aNotebook = [aDecoder decodeObjectForKey:kAppigoNoteNotebookKey];
		if (aNotebook != nil)
			notebook = [[NSString alloc] initWithString:[aNotebook stringByTrimmingCharactersInSet:whitespace]];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:kAppigoNoteNameKey];
	
	if (text != nil)
		[aCoder encodeObject:text forKey:kAppigoNoteTextKey];
	
	if (notebook != nil)
		[aCoder encodeObject:notebook forKey:kAppigoNoteNotebookKey];
}


@end
