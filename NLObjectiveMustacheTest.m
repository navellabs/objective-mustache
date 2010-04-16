#import <SenTestingKit/SenTestingKit.h>
#import "NLObjectiveMustache.h"


#define DICT(...) [NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]


@interface NLObjectiveMustacheTest : SenTestCase {
}

@end


@implementation NLObjectiveMustacheTest


- (void)testTemplateWithNoInterpolationsRendersAsIs
{
    NSString *template = @"this is same";
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:nil];
    STAssertEqualObjects(result, @"this is same", nil);
}


- (void)testSubstitutingAVariableOnASingleLine
{
    NSString *template = @"this is {{variable}}";
    NSDictionary *view = DICT(@"good!", @"variable", nil);
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"this is good!", nil);
}


- (void)testSubstitutingMultipleVariables
{
    NSString *template = @"this is {{variable}}\n and {{more}}";
    NSDictionary *view = DICT(
            @"good!", @"variable",
            @"great!", @"more",
            nil);
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"this is good!\n and great!", nil);
}


- (void)testHandlesEmptySigils
{
    NSString *template = @"this {{}}";
    NSDictionary *view = DICT(@"good!", @"variable", nil);
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"this ", nil);
}


- (void)testWhenTheTemplateStartsWithAnInterpolation
{
    NSString *template = @"{{escape_me}} else";
    NSDictionary *view = DICT(@"something", @"escape_me");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"something else", nil);
}


- (void)testEscapingInterpolatedValues
{
    NSString *template = @"Please {{escape_me}}";
    NSDictionary *view = DICT(@"<>&\"", @"escape_me");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Please &lt;&gt;&amp;&quot;", nil);
}


- (void)testMissingVariablesAreJustIgnored
{
    NSString *template = @"Is this {{missing}}?";
    NSDictionary *view = DICT(@"another", @"value");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Is this ?", nil);
}


- (void)testWorksWithANilView
{
    NSString *template = @"Is this {{missing}}?";
    NSDictionary *view = nil;
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Is this ?", nil);
}


- (void)testBooleanSectionIgnoredWhenFalse
{
    NSString *template = @"Here {{#missing}}this{{/missing}}";
    NSDictionary *view = DICT(@"another", @"value");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Here ", nil);
}


- (void)testBooleanSectionRenderedWhenTrue
{
    NSString *template = @"Here {{#not_missing}}this{{/not_missing}}";
    NSDictionary *view = DICT([NSNumber numberWithBool:YES], @"not_missing");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Here this", nil);
}


- (void)testBooleanSectionWithInnerInterpolations
{
    NSString *template = @"Here {{#not_missing}}this {{value}}{{/not_missing}}";
    NSDictionary *view = DICT(
            [NSNumber numberWithBool:YES], @"not_missing",
            @"one", @"value");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"Here this one", nil);
}


- (void)testNonEscapedInterpolation
{
    NSString *template = @"{{{no_escape}}}";
    NSDictionary *view = DICT(@"<>&", @"no_escape");
    NSString *result = [NLObjectiveMustache stringFromTemplate:template view:view];
    STAssertEqualObjects(result, @"<>&", nil);
}


@end
