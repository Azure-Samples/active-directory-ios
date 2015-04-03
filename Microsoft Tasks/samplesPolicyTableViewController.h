//
//  samplesPolicyTableViewController.h
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/2/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface samplesPolicyTableViewController : UITableViewController

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
