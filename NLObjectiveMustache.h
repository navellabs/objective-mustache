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

#import <Foundation/Foundation.h>


@interface NLObjectiveMustache : NSObject {
    BOOL inVariable;
    NSString *template;
    NSScanner *scanner;
    NSMutableString *results;
    NSDictionary *context;
}

+ (NSString *)stringFromTemplate:(NSString *)template view:(id)view;
+ (NSString *)stringFromTemplateNamed:(NSString *)templateName view:(id)view;

- (NSString *)renderWithView:(id)view;

@property (nonatomic, retain) NSString *template;
@property (nonatomic, retain) NSScanner *scanner;
@property (nonatomic, retain) NSMutableString *results;
@property (nonatomic, retain) NSDictionary *context;

@end
