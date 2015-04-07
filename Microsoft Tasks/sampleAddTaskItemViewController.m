//
//  sampleAddTaskItemViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/4/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import "sampleAddTaskItemViewController.h"
#import "samplesWebAPIConnector.h"
#import "samplesTaskItem.h"
#import "SamplesSelectUserViewController.h"

@implementation sampleAddTaskItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    
    if (self.textField.text.length > 0) {
        
        samplesTaskItem* taskItem = [[samplesTaskItem alloc]init];
        taskItem.itemName = self.textField.text;
        taskItem.completed = NO;
        
        [samplesWebAPIConnector addTask:taskItem parent:self completionBlock:^(bool success, NSError* error) {
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(),^ {
                    
                    [self.navigationController popViewControllerAnimated:TRUE];
                });
            }
            else
            {
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[[NSString alloc]initWithFormat:@"Error : %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:@"Cancel", nil];
                
                [alertView setDelegate:self];
                
                dispatch_async(dispatch_get_main_queue(),^ {
                    [alertView show];
                });
            }
            
        }];
    }
}


- (IBAction)cancelPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        [self save:nil];
    }
}

@end
