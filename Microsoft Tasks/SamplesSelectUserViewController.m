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
#import "SamplesSelectUserViewController.h"
#import "SamplesApplicationData.h"
#import "SamplesTaskListTableViewController.h"

@interface SamplesSelectUserViewController ()

@property NSMutableArray *userList;

@end

@implementation SamplesSelectUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:self.refreshControl];
    self.userList = [[NSMutableArray alloc] init];
    
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
[self loadData];
    
}

-(void) loadData
{
    ADKeychainTokenCache* cache = [ADKeychainTokenCache new];
    NSArray* allItems = [cache allItems:nil];
    
   
        NSMutableSet* users = [NSMutableSet new];
        self.userList = [NSMutableArray new];
    
         for (ADTokenCacheItem* item in allItems)
        {
            ADUserInformation *user = item.userInformation;
            if (!item.userInformation)
            {
                user = [ADUserInformation userInformationWithIdToken:@"Unknown User" error:nil];
            }
            if (![users containsObject:user.userId])
            {
                //New user, add and print:
                [self.userList addObject:item];
                [users addObject:user.userId];
            }
        }
        
        // Refresh main thread since we are async
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    [self.userList removeAllObjects];
    [self.tableView reloadData];
    [self loadData];
    [self.refreshControl endRefreshing];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.userList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPrototypeCell" forIndexPath:indexPath];
    
    ADTokenCacheItem *userItem = [self.userList objectAtIndex:indexPath.row];
    if(userItem)
    {
        if(userItem.userInformation){
            
            cell.textLabel.text = userItem.userInformation.userId;
        }
        else
        {
            cell.textLabel.text = @"ADFS User";
        }
    }
    //    if (taskItem.completed) {
    //        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //    } else {
    //        cell.accessoryType = UITableViewCellAccessoryNone;
    //    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ADTokenCacheItem *userItem = [self.userList objectAtIndex:indexPath.row];
    [self getToken:userItem];
    
    //tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
}

- (void) getToken:(ADTokenCacheItem*) userItem
{
    SamplesApplicationData* appData = [SamplesApplicationData getInstance];
    ADAuthenticationError *error;
    ADAuthenticationContext* authContext = [ADAuthenticationContext authenticationContextWithAuthority:appData.authority validateAuthority:NO error:&error];
    NSString* userId = nil;
    
    if(userItem && userItem.userInformation){
        if(userItem.userInformation.userIdDisplayable){
            userId = userItem.userInformation.userId;
        }
    }
    
    authContext.parentController = self;
    [ADAuthenticationSettings sharedInstance].enableFullScreen = appData.fullScreen;
    
    if(!appData.correlationId ||
       [[appData.correlationId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        authContext.correlationId = [[NSUUID alloc] initWithUUIDString:appData.correlationId];
    }
    
    ADPromptBehavior promptBehavior = AD_PROMPT_AUTO;
    if(!userItem){
        promptBehavior = AD_PROMPT_ALWAYS;
    }
    
    NSURL *redirectUri = [[NSURL alloc]initWithString:appData.redirectUriString];
    [authContext acquireTokenWithResource:appData.resourceId
                                 clientId:appData.clientId
                              redirectUri:redirectUri
                           promptBehavior:promptBehavior
                                   userId:userId
                     extraQueryParameters:@"nux=1"
                          completionBlock:^(ADAuthenticationResult *result) {
                              
                              if (result.status != AD_SUCCEEDED)
                              {
                                  UIAlertController *alert = [UIAlertController
                                                              alertControllerWithTitle:@"Error connecting to Task Service"
                                                              message:[[NSString alloc]initWithFormat:@"Error : %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                                  
                                  UIAlertAction* yesButton = [UIAlertAction
                                                              actionWithTitle:@"Retry"
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  [self getToken:userItem];
                                                                  
                                                              }];
                                  
                                  UIAlertAction* noButton = [UIAlertAction
                                                             actionWithTitle:@"Cancel"
                                                             style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                                 [self loadData];
                                                             }];
                                  
                                  [alert addAction:yesButton];
                                  [alert addAction:noButton];
                                  
                                  [self presentViewController:alert animated:YES completion:nil];
                              }
                              else
                              {
                                  SamplesApplicationData* data = [SamplesApplicationData getInstance];
                                  data.userItem = result.tokenCacheItem;
                                  [self cancelPressed:self];
                              }
                          }];
    
}




@end

