/*
 Copyright (c) 2010 Navel Labs, Ltd.

 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "NLObjectiveMustache.h"


@implementation NLObjectiveMustache


@synthesize template;
@synthesize scanner;
@synthesize results;
@synthesize context;


- (void)dealloc
{
    self.template = nil;
    self.scanner = nil;
    self.results = nil;
    self.context = nil;
    [super dealloc];
}


- (NSScanner *)scanner
{
    if (!scanner) {
        scanner = [[NSScanner scannerWithString:template] retain];
        [scanner setCharactersToBeSkipped:nil];
    }
    return scanner;
}



- (NSString *)escape:(NSString *)string
{
    NSString *result = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return result;
}


- (void)scanToNextInterpolation
{
    NSString *lastFind = nil;
    if ([scanner scanUpToString:@"{{" intoString:&lastFind]) {
        [results appendString:lastFind];
    }
    [scanner scanString:@"{{" intoString:nil];
}


- (void)processSigil
{
    NSString *lastFind = nil;
    [scanner scanUpToString:@"}}" intoString:&lastFind];

    NSString *firstChar = [lastFind substringToIndex:1];
    NSString *interpolatedValue = nil;
    if ([firstChar isEqualToString:@"#"]) {

        NSString *key = [lastFind substringFromIndex:1];
        interpolatedValue = [context valueForKey:key];

        if (![interpolatedValue boolValue]) {
            // Skip to the ending sigil
            NSString *endingSigil = [NSString stringWithFormat:@"{{/%@}}", key];
            [scanner scanUpToString:endingSigil intoString:nil];
        }

    } else if ([firstChar isEqualToString:@"{"]) {

        NSString *key = [lastFind substringFromIndex:1];
        interpolatedValue = [context valueForKey:key];
        if (interpolatedValue) {
            [results appendString:[NSString stringWithFormat:@"%@", interpolatedValue]];
        }
        [scanner scanString:@"}" intoString:nil];

    } else {
        interpolatedValue = [context valueForKey:lastFind];
        if (interpolatedValue) {
            [results appendString:[self escape:[NSString stringWithFormat:@"%@", interpolatedValue]]];
        }
    }

    [scanner scanString:@"}}" intoString:nil];
}


- (NSString *)renderWithView:(id)view
{
    self.results = [NSMutableString stringWithCapacity:500];
    self.context = view;
    self.scanner = nil;
    self.scanner; // Spins up a new copy

    while ([scanner isAtEnd] == NO) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        [self scanToNextInterpolation];

        if (![scanner isAtEnd]) {
            [self processSigil];
        }

        [pool drain];
    }

    self.scanner = nil;

    return self.results;
}


+ (NSString *)stringFromTemplate:(NSString *)template view:(id)view
{
    NLObjectiveMustache *mustache = [[NLObjectiveMustache alloc] init];
    mustache.template = template;
    NSString *result = [mustache renderWithView:view];
    [mustache release];
    return result;
}


+ (NSString *)stringFromTemplateNamed:(NSString *)templateName view:(id)view
{
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"mustache"];
    NSString *fileTemplate = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *html = [NLObjectiveMustache stringFromTemplate:fileTemplate view:view];

    return html;
}


@end
