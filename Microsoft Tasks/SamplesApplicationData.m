#import "SamplesApplicationData.h"

@implementation SamplesApplicationData

+(id) getInstance
{
    static SamplesApplicationData *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]];
        NSString* va = [dictionary objectForKey:@"fullScreen"];
        instance.fullScreen = [va boolValue];
        instance.clientId = [dictionary objectForKey:@"clientId"];
        instance.authority = [dictionary objectForKey:@"authority"];
        instance.resourceId = [dictionary objectForKey:@"resourceString"];
        instance.redirectUriString = [dictionary objectForKey:@"redirectUri"];
        instance.taskWebApiUrlString = [dictionary objectForKey:@"taskWebAPI"];
        
    });
    
    return instance;
}

@end