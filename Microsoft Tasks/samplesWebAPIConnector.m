//
//  samplesWebAPIConnector.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/11/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import "samplesWebAPIConnector.h"
#import "ADALiOS/ADAuthenticationContext.h"
#import "samplesTaskItem.h"

@implementation samplesWebAPIConnector

ADAuthenticationContext* authContext;
static NSMutableArray* tasks;
static NSMutableDictionary *taskList;
static NSMutableDictionary* taskDetails;
NSString* taskWebApiUrlString;
NSString* authority;
NSString* clientId;
NSString* resourceId;
NSString* redirectUriString;
NSString* userId;
NSString* tenantId;
NSString* upn;

- (id)init
{
    self = [super init];
    if (self)
    {
        
        
    }
    return self;
}

+ (void) readApplicationSettings {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]];
    
    clientId = [dictionary objectForKey:@"clientId"];
    authority = [dictionary objectForKey:@"authority"];
    resourceId = [dictionary objectForKey:@"resourceString"];
    redirectUriString = [dictionary objectForKey:@"redirectUri"];
    userId = [dictionary objectForKey:@"userId"];
    taskWebApiUrlString = [dictionary objectForKey:@"taskWebAPI"];
}

+(NSString*) trimString: (NSString*) toTrim
{
    //The white characters set is cached by the system:
    NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [toTrim stringByTrimmingCharactersInSet:set];
}

+(void)getTokenForNoReason
{
   [self getToken:NO completionHandler:^(NSString* accessToken){ }];
}

+(void) getToken : (BOOL) clearCache completionHandler:(void (^) (NSString*))completionBlock;
{
    [self readApplicationSettings];
    [self getToken:clearCache resource:resourceId completionHandler:completionBlock];
}

+(void) getToken : (BOOL) clearCache resource:(NSString*) resource completionHandler:(void (^) (NSString*))completionBlock
{
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority error:&error];
    
    NSURL *redirectUri = [[NSURL alloc]initWithString:redirectUriString];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [userDefaults objectForKey:@"defaultUserId"];
    
    if(clearCache)
    {
        [authContext.tokenCacheStore removeAll];
    }
    
    [authContext acquireTokenWithResource:resource clientId:clientId redirectUri:redirectUri userId:userId completionBlock:^(ADAuthenticationResult *result) {
        
        if (result.tokenCacheStoreItem == nil)
        {
            // display error on the screen
        }
        else
        {
            tenantId = result.tokenCacheStoreItem.userInformation.tenantId;
            upn = result.tokenCacheStoreItem.userInformation.userId;
            completionBlock(result.tokenCacheStoreItem.accessToken);
        }
    }
     ];
}


+(void) getTaskList:(void (^) (NSArray*))completionBlock;
{
    if (taskDetails != nil && [taskDetails objectForKey:tasks] != nil)
    {
 //       [delegate updateTaskList:[[taskDetails objectForKey:tasks] allValues]];
    }
    else
    {
        if (taskDetails == nil)
        {
            taskDetails = [[NSMutableDictionary alloc]init];
        }
        
        
        [self getToken:NO completionHandler:^(NSString* accessToken){
            
           NSURL *taskWebApiURL = [[NSURL alloc]initWithString:[self.class trimString:taskWebApiUrlString]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:taskWebApiURL];
            
            NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", accessToken];
            
            [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error == nil && data != nil){
                    
    //                NSString* stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSArray *tasks = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                   //each object is a key value pair
                    NSDictionary *keyValuePairs;
                    
                    for(int i =0; i < tasks.count; i++)
                    {
                        keyValuePairs = [tasks objectAtIndex:i];
                        
                        samplesTaskItem *s = [[samplesTaskItem alloc]init];
                        
                        s.itemName = [keyValuePairs valueForKey:@"Title"];
                        
                    }
                    
                    completionBlock(tasks);
                    
                }
                
            }];
            
        }];
    }
    

}

+(void) craftRequest : (NSString*)webApiUrlString completionHandler:(void (^)(NSMutableURLRequest*))completionBlock
{
    [self getToken:NO completionHandler:^(NSString* accessToken){
        
        NSURL *webApiURL = [[NSURL alloc]initWithString:webApiUrlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:webApiURL];
        
        NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", accessToken];
        
        [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
        
        completionBlock(request);
        
    }
     ];
}

+(void) addTask:(samplesTaskItem*)task completionBlock:(void (^) (bool)) completionBlock
{
    [self craftRequest:taskWebApiUrlString completionHandler:^(NSMutableURLRequest* request){
        
        NSDictionary* taskInDictionaryFormat = [self convertTaskToDictionary:task];
        
        NSData* requestBody = [NSJSONSerialization dataWithJSONObject:taskInDictionaryFormat options:0 error:nil];
        
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:requestBody];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", content);
            
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            int responseStatusCode = [httpResponse statusCode];
            
            if (error == nil && responseStatusCode == 200){
                
                completionBlock(true);
            }
            else
            {
                completionBlock(false);
            }
        }
         ];
    }
     ];
}

+(NSDictionary*) convertTaskToDictionary:(samplesTaskItem*)task
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    
    
    if (task.itemName){
        [dictionary setValue:task.itemName forKey:@"Title"];
    }
    if (task.ownerName) {
        [dictionary setValue:upn forKey:@"Owner"];
    }
    
    
    return dictionary;
}

+(void) signOut
{
    [authContext.tokenCacheStore removeAll];
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}



@end
