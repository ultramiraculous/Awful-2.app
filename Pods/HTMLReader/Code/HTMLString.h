//
//  HTMLString.h
//  HTMLReader
//
//  Created by Nolan Waite on 2013-07-02.
//

#import <Foundation/Foundation.h>

// These are internal methods, so they should stay out of categories on Foundation classes.

/**
 * Append a single Unicode code point to an NSMutableString. This takes care of code points that require the use of surrogate pairs.
 *
 * @param self The NSMutableString that will get a character.
 * @param character The character to append.
 */
extern inline void AppendLongCharacter(NSMutableString *self, UTF32Char character);

/**
 * Execute a block on every Unicode code point in a string. This takes care of code points that require the use of surrogate pairs.
 *
 * @param self The string whose code points are enumerated.
 * @param block The block to execute, which has no return value and takes a code point as its sole parameter.
 */
extern void EnumerateLongCharacters(NSString *self, void (^block)(UTF32Char character));
