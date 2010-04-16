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


- (NSString *)renderWithView:(NSDictionary *)view
{
    self.results = [NSMutableString stringWithCapacity:500];
    self.context = view;
    self.scanner = nil;
    self.scanner; // Spins up a new copy

    while ([scanner isAtEnd] == NO) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        [self scanToNextInterpolation];

        if ([scanner isAtEnd]) {
            continue;
        }

        [self processSigil];

        [pool drain];
    }

    self.scanner = nil;

    return self.results;
}


+ (NSString *)stringFromTemplate:(NSString *)template view:(NSDictionary *)view
{
    NLObjectiveMustache *mustache = [[NLObjectiveMustache alloc] init];
    mustache.template = template;
    NSString *result = [mustache renderWithView:view];
    [mustache release];
    return result;
}


+ (NSString *)stringFromTemplateNamed:(NSString *)templateName view:(NSDictionary *)view
{
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"mustache"];
    NSString *fileTemplate = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSString *html = [NLObjectiveMustache stringFromTemplate:fileTemplate view:view];

    return html;
}


@end
