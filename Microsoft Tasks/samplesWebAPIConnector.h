//
//  samplesWebAPIConnector.h
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/11/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "samplesTaskItem.h"

@interface samplesWebAPIConnector : NSObject<NSURLConnectionDataDelegate>

+(void) getTokenForNoReason;
+(void) getTaskList:(void (^) (NSArray*))completionBlock;
+(void) addTask:(samplesTaskItem*)task completionBlock:(void (^) (bool)) completionBlock;
+(NSDictionary*) convertTaskToDictionary:(samplesTaskItem*)task;
+(void) signOut;


@end
