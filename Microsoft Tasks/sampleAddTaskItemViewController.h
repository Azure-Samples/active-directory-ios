//
//  sampleAddTaskItemViewController.h
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/4/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sampleAddTaskItemViewController : UIViewController<UIAlertViewDelegate>

- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)cancelPressed:(id)sender;
@end
