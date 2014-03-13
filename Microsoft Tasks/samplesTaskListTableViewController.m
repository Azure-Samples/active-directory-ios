//
//  samplesTaskListTableViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/4/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import "samplesTaskListTableViewController.h"
#import "samplesTaskItem.h"
#import "sampleAddTaskItemViewController.h"
#import "samplesWebAPIConnector.h"
#import "ADALiOS/ADAuthenticationContext.h"

@interface samplesTaskListTableViewController ()

@property NSMutableArray *taskItems;
@property ADAuthenticationContext *authContext;

@end

@implementation samplesTaskListTableViewController

-(void)loadData {
    
    // Load data from the webservice
    
    
   [samplesWebAPIConnector getTaskList:^(NSArray *tasks) {
        
        //each object is a key value pair
        NSDictionary *keyValuePairs;
        
        for(int i =0; i < tasks.count; i++)
        {
            samplesTaskItem *item = [[samplesTaskItem alloc] init];
            keyValuePairs = [tasks objectAtIndex:i];
            item.itemName = [keyValuePairs valueForKey:@"Title"];
            [self.taskItems addObject:item];
            
            // Refresh main thread since we are async
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
    }];
    
}

-(IBAction)unwindTaskList:(UIStoryboardSegue *)segue {
    
    sampleAddTaskItemViewController *source = [segue sourceViewController];
    samplesTaskItem *item = source.taskItem;
    
    if (item != nil) {
        // Refresh main thread since we are async
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    

    
}

- (IBAction)pressedLogout:(id)sender {
    
    [samplesWebAPIConnector signOut];
    [self.taskItems removeAllObjects];
    
    // Refresh main thread since we are async
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    [self loadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.taskItems = [[NSMutableArray alloc] init];
    [self loadData];


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
    
    
    
    samplesTaskItem *taskItem = [self.taskItems objectAtIndex:indexPath.row];
    cell.textLabel.text = taskItem.itemName;
    
    if (taskItem.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    samplesTaskItem *tappedItem = [self.taskItems objectAtIndex:indexPath.row];
    tappedItem.completed = !tappedItem.completed;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}



@end
