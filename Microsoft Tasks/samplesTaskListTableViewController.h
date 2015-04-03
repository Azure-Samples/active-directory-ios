//
//  samplesTaskListTableViewController.h
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/4/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface samplesTaskListTableViewController : UITableViewController<UIAlertViewDelegate>

- (IBAction)switchUserPressed:(id)sender;
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
