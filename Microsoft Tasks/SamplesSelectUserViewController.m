#import "SamplesSelectUserViewController.h"
#import <ADAuthenticationSettings.h>
#import "ADALiOS/ADAuthenticationContext.h"
#import "SamplesApplicationData.h"
#import "samplesTaskListTableViewController.h"

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
    ADAuthenticationError* error;
    id<ADTokenCacheStoring> cache = [ADAuthenticationSettings sharedInstance].defaultTokenCacheStore;
    NSArray* array = [cache allItemsWithError:&error];
    
    if (error)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[[NSString alloc]initWithFormat:@"%@", error.errorDetails] delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
        
        [alertView setDelegate:self];
        
        dispatch_async(dispatch_get_main_queue(),^ {
            [alertView show];
        });
    } else
    {
        NSMutableSet* users = [NSMutableSet new];
        self.userList = [NSMutableArray new];
        for(ADTokenCacheStoreItem* item in array)
        {
            ADUserInformation *user = item.userInformation;
            if (!item.userInformation)
            {
                user = [ADUserInformation userInformationWithUserId:@"Unknown user" error:nil];
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
    
    ADTokenCacheStoreItem *userItem = [self.userList objectAtIndex:indexPath.row];
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
    ADTokenCacheStoreItem *userItem = [self.userList objectAtIndex:indexPath.row];
    [self getToken:userItem];
    
    //tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
}

- (void) getToken:(ADTokenCacheStoreItem*) userItem
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
                                  UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[[NSString alloc]initWithFormat:@"Error : %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                  
                                  [alertView setDelegate:self];
                                  
                                  dispatch_async(dispatch_get_main_queue(),^ {
                                      [alertView show];
                                  });
                              }
                              else
                              {
                                  SamplesApplicationData* data = [SamplesApplicationData getInstance];
                                  data.userItem = result.tokenCacheStoreItem;
                                  [self cancelPressed:self];
                              }
                          }];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [self loadData];
    }
}



@end

