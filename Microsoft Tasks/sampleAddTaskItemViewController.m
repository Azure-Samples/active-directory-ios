//
//  sampleAddTaskItemViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 3/4/14.
//  Copyright (c) 2014 Microsoft. All rights reserved.
//

#import "sampleAddTaskItemViewController.h"
#import "samplesWebAPIConnector.h"

@interface sampleAddTaskItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (sender != self.saveButton) {
        return;
    }
    if (self.textField.text.length > 0) {
        self.taskItem = [[samplesTaskItem alloc] init];
        self.taskItem.itemName = self.textField.text;
        self.taskItem.completed = NO;
    }
    
    [samplesWebAPIConnector addTask:self.taskItem completionBlock:^(bool success) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(),^ {
                
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            // display error
        }
        
    }];

}


@end
