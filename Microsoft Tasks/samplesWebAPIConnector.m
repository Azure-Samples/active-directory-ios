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
#import "ADALiOS/ADAuthenticationSettings.h"

@implementation samplesWebAPIConnector

ADAuthenticationContext* authContext;

NSString* taskWebApiUrlString;
NSString* authority;
NSString* clientId;
NSString* resourceId;
NSString* redirectUriString;
NSString* userId;
NSString* tenantId;
NSString* upn;

bool loadedApplicationSettings;

+ (void) readApplicationSettings {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]];
    
    clientId = [dictionary objectForKey:@"clientId"];
    authority = [dictionary objectForKey:@"authority"];
    resourceId = [dictionary objectForKey:@"resourceString"];
    redirectUriString = [dictionary objectForKey:@"redirectUri"];
    userId = [dictionary objectForKey:@"userId"];
    taskWebApiUrlString = [dictionary objectForKey:@"taskWebAPI"];
    
    loadedApplicationSettings = YES;
}

+(NSString*) trimString: (NSString*) toTrim
{
    //The white characters set is cached by the system:
    NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [toTrim stringByTrimmingCharactersInSet:set];
}

+(void) getToken : (BOOL) clearCache completionHandler:(void (^) (NSString*, NSError*))completionBlock;
{
    [self readApplicationSettings];
    [self getToken:clearCache resource:resourceId completionHandler:completionBlock];
}

+(void) getToken : (BOOL) clearCache resource:(NSString*) resource completionHandler:(void (^) (NSString*, NSError*))completionBlock
{
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority validateAuthority:NO error:&error];
    [[ADAuthenticationSettings sharedInstance] setSharedCacheKeychainGroup:@"J4DR8GHCZT.com.sri.Shared"];
    
    NSURL *redirectUri = [[NSURL alloc]initWithString:redirectUriString];
    
    if(clearCache)
    {
        [authContext.tokenCacheStore removeAllWithError:nil];
    }
    
    [authContext acquireTokenWithResource:resource clientId:clientId redirectUri:redirectUri userId:userId completionBlock:^(ADAuthenticationResult *result) {
        
        if (result.tokenCacheStoreItem == nil)
        {
            completionBlock(nil, result.error);
        }
        else
        {
            tenantId = result.tokenCacheStoreItem.userInformation.tenantId;
            upn = result.tokenCacheStoreItem.userInformation.userId;
            completionBlock(result.tokenCacheStoreItem.accessToken, nil);
        }
    }];
}

+(void) getTaskList:(void (^) (NSArray*, NSError*))completionBlock;
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    [self craftRequest:[self.class trimString:taskWebApiUrlString] completionHandler:^(NSMutableURLRequest *request, NSError *error) {
        
        if (error != nil)
        {
            completionBlock(nil, error);
        }
        else
        {
            
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error == nil && data != nil){
                    
                    NSArray *tasks = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    //each object is a key value pair
                    NSDictionary *keyValuePairs;
                    NSMutableArray* sampleTaskItems = [[NSMutableArray alloc]init];
                    
                    for(int i =0; i < tasks.count; i++)
                    {
                        keyValuePairs = [tasks objectAtIndex:i];
                        
                        samplesTaskItem *s = [[samplesTaskItem alloc]init];
                        s.itemName = [keyValuePairs valueForKey:@"Title"];
                        
                        [sampleTaskItems addObject:s];
                    }
                    
                    completionBlock(sampleTaskItems, nil);
                }
                else
                {
                    completionBlock(nil, error);
                }
                
            }];
        }
    }];
    
}

+(void) addTask:(samplesTaskItem*)task completionBlock:(void (^) (bool, NSError* error)) completionBlock
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    [self craftRequest:taskWebApiUrlString completionHandler:^(NSMutableURLRequest* request, NSError* error){
        
        if (error != nil)
        {
            completionBlock(NO, error);
        }
        else
        {
            NSDictionary* taskInDictionaryFormat = [self convertTaskToDictionary:task];
            
            NSData* requestBody = [NSJSONSerialization dataWithJSONObject:taskInDictionaryFormat options:0 error:nil];
            
            [request setHTTPMethod:@"POST"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:requestBody];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", content);
                
                if (error == nil){
                    
                    completionBlock(true, nil);
                }
                else
                {
                    completionBlock(false, error);
                }
            }];
        }
    }];
}

+(void) craftRequest : (NSString*)webApiUrlString completionHandler:(void (^)(NSMutableURLRequest*, NSError* error))completionBlock
{
    [self getToken:NO completionHandler:^(NSString* accessToken, NSError* error){
        
        if (accessToken == nil)
        {
            completionBlock(nil,error);
        }
        else
        {
            NSURL *webApiURL = [[NSURL alloc]initWithString:webApiUrlString];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:webApiURL];
            
            NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", accessToken];
            
            [request addValue:authHeader forHTTPHeaderField:@"Authorization"];
            
            completionBlock(request, nil);
        }
    }];
}

+(NSDictionary*) convertTaskToDictionary:(samplesTaskItem*)task
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    
    if (task.itemName){
        [dictionary setValue:task.itemName forKey:@"Title"];
    }
    
    return dictionary;
}

+(void) signOut
{
    [authContext.tokenCacheStore removeAllWithError:nil];
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

@end
