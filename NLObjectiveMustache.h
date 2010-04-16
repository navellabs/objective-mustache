#import <Foundation/Foundation.h>


@interface NLObjectiveMustache : NSObject {
    BOOL inVariable;
    NSString *template;
    NSScanner *scanner;
    NSMutableString *results;
    NSDictionary *context;
}

+ (NSString *)stringFromTemplate:(NSString *)template view:(NSDictionary *)view;
+ (NSString *)stringFromTemplateNamed:(NSString *)templateName view:(NSDictionary *)view;

- (NSString *)renderWithView:(NSDictionary *)view;

@property (nonatomic, retain) NSString *template;
@property (nonatomic, retain) NSScanner *scanner;
@property (nonatomic, retain) NSMutableString *results;
@property (nonatomic, retain) NSDictionary *context;

@end
