//
//  samplesAddPolicyViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/2/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "samplesAddPolicyViewController.h"

@interface samplesAddPolicyViewController ()
@property (weak, nonatomic) IBOutlet UITextField *policyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *policyIDTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation samplesAddPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (sender != self.saveButton) return;
    if (self.policyIDTextField.text.length > 0 && self.policyNameTextField > 0) {
        self.policyItem = [[ samplesPolicyData alloc] init];
        self.policyItem.policyName = self.policyNameTextField.text;
        self.policyItem.policyID = self.policyIDTextField.text;
    }
}


@end
