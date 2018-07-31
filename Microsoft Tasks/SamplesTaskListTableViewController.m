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
#import "SamplesTaskListTableViewController.h"
#import "SamplesApplicationData.h"
#import "SamplesTaskItem.h"
#import "SampleAddTaskItemViewController.h"
#import "SamplesWebAPIConnector.h"
#import "SamplesSelectUserViewController.h"

@interface SamplesTaskListTableViewController ()

@property NSMutableArray *taskItems;
@property ADAuthenticationContext *authContext;
@property (weak, nonatomic) IBOutlet UILabel* userLabel;

@end

@implementation SamplesTaskListTableViewController

-(void)loadData {
    
    SamplesApplicationData* appData = [SamplesApplicationData getInstance];
    
    if (!appData.userItem.userInformation.userId) {
        
        dispatch_async(dispatch_get_main_queue(),^ {
            
            SamplesSelectUserViewController* userSelectController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectUserView"];
            [self.navigationController pushViewController:userSelectController animated:YES];
        });
    }

    
    // Load data from the webservice
    if (appData.userItem) {
        
    [SamplesWebAPIConnector getTaskList:^(NSArray *tasks, NSError* error) {
        
        if (error != nil && appData.userItem)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[[NSString alloc]initWithFormat:@"%@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
            
            [alertView setDelegate:self];
            
            dispatch_async(dispatch_get_main_queue(),^ {
                [alertView show];
            });
        }
        else
        {
            self.taskItems = (NSMutableArray*)tasks;
            
            // Refresh main thread since we are async
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                SamplesApplicationData* appData = [SamplesApplicationData getInstance];
                if(appData.userItem && appData.userItem.userInformation.userId)
                {
                    [self.userLabel setText:appData.userItem.userInformation.userId];
                }
                else
                {
                    [self.userLabel setText:@"N/A" ];
                }
            });
        }
    } parent:self];
    } }

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:self.refreshControl];
    self.taskItems = [[NSMutableArray alloc] init];
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    SamplesApplicationData* appData = [SamplesApplicationData getInstance];
    
    if(appData.userItem)
    {
        [self loadData];
    }
    
    if(appData.userItem && appData.userItem.userInformation.userId)
    {
        [self.userLabel setText:appData.userItem.userInformation.userId];    }
    else
    {
        [self.userLabel setText:@"N/A" ];
    }
}


-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    [self.taskItems removeAllObjects];
    [self.tableView reloadData];
    [self loadData];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.taskItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskPrototypeCell" forIndexPath:indexPath];
    
    SamplesTaskItem *taskItem = [self.taskItems objectAtIndex:indexPath.row];
    cell.textLabel.text = taskItem.itemName;
    
    if (taskItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SamplesTaskItem *tappedItem = [self.taskItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
     
         
         SamplesTaskItem *selectedItem = [self.taskItems objectAtIndex:indexPath.row];
         [SamplesWebAPIConnector deleteTask:selectedItem parent:self completionBlock:^(bool success, NSError* error) {
            
             if (error != nil) {

                 UIAlertController *alert = [UIAlertController
                                             alertControllerWithTitle:@"Error connecting to Task Service"
                                             message:[[NSString alloc]initWithFormat:@"Error : %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                 
                 
                 UIAlertAction* noButton = [UIAlertAction
                                            actionWithTitle:@"Cancel"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            }];
                 
                 [alert addAction:noButton];
                 
                 [self presentViewController:alert animated:YES completion:nil];
             }
             
             }];
     
     [self.taskItems removeObjectAtIndex:indexPath.row];
     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     
     }
     
     [self.taskItems removeAllObjects];
     [self.tableView reloadData];
     [self loadData];

 
 }




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

@end
