//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------


#import <ADAL/ADAL.h>
#import "SamplesApplicationData.h"
#import "SamplesWebAPIConnector.h"
#import "SamplesTaskItem.h"
#import "SamplesPolicyData.h"
#import "NSDictionary+UrlEncoding.h"

@implementation SamplesWebAPIConnector

ADAuthenticationContext* authContext;
bool loadedApplicationSettings;

+ (void) readApplicationSettings {
    loadedApplicationSettings = YES;
}

+(NSString*) trimString: (NSString*) toTrim
{
    //The white characters set is cached by the system:
    NSCharacterSet* set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [toTrim stringByTrimmingCharactersInSet:set];
}

//getToken for generic Web API flows. Returns a token with no additional parameters provided.
//
//

+(void) getToken : (BOOL) clearCache
           parent:(UIViewController*) parent
completionHandler:(void (^) (NSString*, NSError*))completionBlock;
{
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    if(data.userItem){
        completionBlock(data.userItem.accessToken, nil);
        return;
    }
    
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:data.authority error:&error];
    authContext.parentController = parent;
    NSURL *redirectUri = [[NSURL alloc]initWithString:data.redirectUriString];
    
    if(!data.correlationId ||
       [[data.correlationId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        authContext.correlationId = [[NSUUID alloc] initWithUUIDString:data.correlationId];
    }
    
    [ADAuthenticationSettings sharedInstance].enableFullScreen = data.fullScreen;
    [authContext acquireTokenWithResource:data.resourceId
                                 clientId:data.clientId
                              redirectUri:redirectUri
                           promptBehavior:AD_PROMPT_AUTO
                                   userId:data.userItem.userInformation.userId
                     extraQueryParameters: nil
                          completionBlock:^(ADAuthenticationResult *result) {
        
        if (result.status != AD_SUCCEEDED)
        {
            completionBlock(nil, result.error);
        }   
        else
        {
            data.userItem = result.tokenCacheItem;
            completionBlock(result.tokenCacheItem.accessToken, nil);
        }
    }];
}

//getToken for support of sending extra (and unknown) params to the authorization and token endpoints
//
//

+(void) getTokenWithExtraParams : (BOOL) clearCache
                          params:(NSDictionary*) params
                          parent:(UIViewController*) parent
               completionHandler:(void (^) (NSString*, NSError*))completionBlock;
{
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    
    
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:data.authority error:&error];
    authContext.parentController = parent;
    NSURL *redirectUri = [[NSURL alloc]initWithString:data.redirectUriString];
    
    if(!data.correlationId ||
       [[data.correlationId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        authContext.correlationId = [[NSUUID alloc] initWithUUIDString:data.correlationId];
    }
    
    [ADAuthenticationSettings sharedInstance].enableFullScreen = data.fullScreen;
    [authContext acquireTokenWithResource:data.resourceId
                                 clientId:data.clientId
                              redirectUri:redirectUri
                           promptBehavior:AD_PROMPT_AUTO
                                   userId:data.userItem.userInformation.userId
                     extraQueryParameters: params.urlEncodedString
                          completionBlock:^(ADAuthenticationResult *result) {
                              
                              if (result.status != AD_SUCCEEDED)
                              {
                                  completionBlock(nil, result.error);
                              }
                              else
                              {
                                  data.userItem = result.tokenCacheItem;
                                  completionBlock(result.tokenCacheItem.accessToken, nil);
                              }
                          }];
}

// getToken for support of sending extra (and unknown) params to the authorization and token endpoints.
// This method returns the entire claimset as stored in the userInformation collection instead of a token.
// Use this only for display purposes, it is not necessary

+(void) getClaimsWithExtraParams : (BOOL) clearCache
                           params:(NSDictionary*) params
                           parent:(UIViewController*) parent
                completionHandler:(void (^) (ADUserInformation*, NSError*))completionBlock;
{
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    
    
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:data.authority error:&error];
    authContext.parentController = parent;
    NSURL *redirectUri = [[NSURL alloc]initWithString:data.redirectUriString];
    
    if(!data.correlationId ||
       [[data.correlationId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        authContext.correlationId = [[NSUUID alloc] initWithUUIDString:data.correlationId];
    }
    
    [ADAuthenticationSettings sharedInstance].enableFullScreen = data.fullScreen;
    [authContext acquireTokenWithResource:data.resourceId
                                 clientId:data.clientId
                              redirectUri:redirectUri
                           promptBehavior:AD_PROMPT_ALWAYS
                                   userId:data.userItem.userInformation.userId
                     extraQueryParameters: params.urlEncodedString
                          completionBlock:^(ADAuthenticationResult *result) {
                              
                              if (result.status != AD_SUCCEEDED)
                              {
                                  completionBlock(nil, result.error);
                              }
                              else
                              {
                                  data.userItem = result.tokenCacheItem;
                                  completionBlock(result.tokenCacheItem.userInformation, nil);
                              }
                          }];
}


// This method returns the entire claimset as stored in the userInformation collection instead of a token.
// This is meant to show that Claims can be retreived without extra query params. You could easily pass getClaimsWithExtraParams with params = nil.

+(void) getClaims : (BOOL) clearCache
            parent:(UIViewController*) parent
 completionHandler:(void (^) (ADUserInformation*, NSError*))completionBlock;
{
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    
    ADAuthenticationError *error;
    authContext = [ADAuthenticationContext authenticationContextWithAuthority:data.authority error:&error];
    authContext.parentController = parent;
    NSURL *redirectUri = [[NSURL alloc]initWithString:data.redirectUriString];
    
    if(!data.correlationId ||
       [[data.correlationId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        authContext.correlationId = [[NSUUID alloc] initWithUUIDString:data.correlationId];
    }
    
    [ADAuthenticationSettings sharedInstance].enableFullScreen = data.fullScreen;
    [authContext acquireTokenWithResource:data.resourceId
                                 clientId:data.clientId
                              redirectUri:redirectUri
                           promptBehavior:AD_PROMPT_ALWAYS
                                   userId:nil
                     extraQueryParameters:nil

                          completionBlock:^(ADAuthenticationResult *result) {
                              
                              if (result.status != AD_SUCCEEDED)
                              {
                                  completionBlock(nil, result.error);
                              }
                              else
                              {
                                  data.userItem = result.tokenCacheItem;
                                  completionBlock(result.tokenCacheItem.userInformation, nil);
                              }
                          }];
}

+(void) getTaskList:(void (^) (NSArray*, NSError*))completionBlock
             parent:(UIViewController*) parent;
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [self craftRequest:[self.class trimString:data.taskWebApiUrlString]
                parent:parent
     completionHandler:^(NSMutableURLRequest *request, NSError *error) {
        
        if (error != nil)
        {
            completionBlock(nil, error);
        }
        else
        {
            

            
            [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response,  NSError *error) {
                
                if (error == nil && data != nil){
                    
                    NSArray *tasks = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    //each object is a key value pair
                    NSDictionary *keyValuePairs;
                    NSMutableArray* sampleTaskItems = [[NSMutableArray alloc]init];
                    
                    for(int i =0; i < tasks.count; i++)
                    {
                        keyValuePairs = [tasks objectAtIndex:i];
                        
                        SamplesTaskItem *s = [[SamplesTaskItem alloc]init];
                        s.itemName = [keyValuePairs valueForKey:@"Text"];
                        
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

+(void) addTask:(SamplesTaskItem*)task
         parent:(UIViewController*) parent
completionBlock:(void (^) (bool, NSError* error)) completionBlock
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [self craftRequest:data.taskWebApiUrlString parent:parent completionHandler:^(NSMutableURLRequest* request, NSError* error){
        
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
            
            
            [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response,  NSError *error) {
                
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

+(void) deleteTask:(SamplesTaskItem*)task
         parent:(UIViewController*) parent
completionBlock:(void (^) (bool, NSError* error)) completionBlock
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [self craftRequest:data.taskWebApiUrlString parent:parent completionHandler:^(NSMutableURLRequest* request, NSError* error){
        
        if (error != nil)
        {
            completionBlock(NO, error);
        }
        else
        {
            NSDictionary* taskInDictionaryFormat = [self convertTaskToDictionary:task];
            
            NSData* requestBody = [NSJSONSerialization dataWithJSONObject:taskInDictionaryFormat options:0 error:nil];
            
            [request setHTTPMethod:@"DELETE"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:requestBody];
            
            NSLog(@"%@", request);
            
            
            
            [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response,  NSError *error) {
                
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


// A simple callback that makes sense of all the getClaims* above.

+(void) doLogin:(BOOL) prompt
         parent:(UIViewController*) parent
completionBlock:(void (^) (ADUserInformation* userInfo, NSError* error)) completionBlock
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    [self getClaims:NO parent:parent completionHandler:^(ADUserInformation* userInfo, NSError* error) {
        
        if (userInfo == nil)
        {
            completionBlock(nil, error);
        }
        
        else {
            
            completionBlock(userInfo, nil);
        }
    }];
    
}

// Although not yet used in this sample, this demonstrates how you could pass policies to the server.
// See the Native-iOS-B2C sample for more information.

+(void) doPolicy:(SamplesPolicyData *)policy
          parent:(UIViewController*) parent
 completionBlock:(void (^) (ADUserInformation* userInfo, NSError* error)) completionBlock
{
    if (!loadedApplicationSettings)
    {
        [self readApplicationSettings];
    }
    
    NSDictionary* params = [self convertPolicyToDictionary:policy];
    
    [self getClaimsWithExtraParams:NO params:params parent:parent completionHandler:^(ADUserInformation* userInfo, NSError* error) {
        
        if (userInfo == nil)
        {
            completionBlock(nil, error);
        }
        
        else {
            
            completionBlock(userInfo, nil);
        }
    }];
    
}

+(void) craftRequest : (NSString*)webApiUrlString
               parent:(UIViewController*) parent
    completionHandler:(void (^)(NSMutableURLRequest*, NSError* error))completionBlock
{
    [self getToken:NO parent:parent completionHandler:^(NSString* accessToken, NSError* error){
        
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

// Here we have some converstion helpers that allow us to parse passed items in to dictionaries for URLEncoding later.

+(NSDictionary*) convertTaskToDictionary:(SamplesTaskItem*)task
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    
    if (task.itemName){
        [dictionary setValue:task.itemName forKey:@"Text"];
    }
    
    return dictionary;
}

+(NSDictionary*) convertPolicyToDictionary:(SamplesPolicyData*)policy
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    
    // Using UUID for nonce. Not recommended.
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    
    if (policy.policyID){
        [dictionary setValue:policy.policyID forKey:@"p"];
        [dictionary setValue:@"openid" forKey:@"scope"];
        [dictionary setValue:UUID forKey:@"nonce"];
        [dictionary setValue:@"query" forKey:@"response_mode"];
        [dictionary setValue:@"1" forKey:@"nux"];
    }
    
    return dictionary;
}



+(void) signOut
{
    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    
    // We remove the user from the keychain with a particular userID.
    
    ADKeychainTokenCache* cache = [ADKeychainTokenCache new];
    [cache removeAllForUserId:data.userItem.userInformation.userId clientId:data.userItem.clientId error:nil];
    
    NSHTTPCookie *cookie;
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

@end
