/**
 
 Appigo Third Party Integration - AppigoNote.h
 
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
 @file AppigoNote.h
 @brief A class for representing an importable note.
 
 @class AppigoNote AppigoNote.h
 @brief A class for representing an importable note.
 
 A class to represent a note that can be placed on the Appigo Pasteboard and
 referenced by Appigo Applications.
 */


#import <Foundation/Foundation.h>


@class AppigoTask;


@interface AppigoNote : NSObject <NSCoding>
{
	NSString	*name;
	NSString	*text;
	NSString	*notebook;
}

/** The name/title of the note. */
@property (nonatomic, readonly) NSString *name;

/** The note's text which does not include the name. */
@property (nonatomic, retain) NSString *text;

/**
 A case-insensitive notebook name that the note belongs to.  If a
 matching notebook is found in Notebook, the note will be placed inside
 the corresponding notebook when imported.  If multiple notebooks with
 the same name exist in Notebook, the notebook used for this note is
 undefined.  If a matching notebook name is not found during import, the
 notebook will be created before assigning the note to the notebook.
 */
@property (nonatomic, retain) NSString *notebook;

/**
 Initialize a new note object.
 
 @param noteName The note name. The name will be trimmed of whitespace (an
 empty name is invalid and will be replaced with, "Unknown").
 */
- (id)initWithName:(NSString *)noteName;

/**
 Get a plain text representation of a note.
 
 @param includeName Specify YES to include the name in the text representation
 or NO to omit it.
 @return Returns a plain text representation of the note.
 */
- (NSString *)plainTextRepresentationWithName:(BOOL)includeName;

/**
 Build an AppigoTask object from the note that can be used to import the note
 into Appigo Todo.
 
 @return Returns an AppigoTask object.
 */
- (AppigoTask *)taskRepresentation;

@end
