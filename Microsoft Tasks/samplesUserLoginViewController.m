//
//  samplesUserLoginViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/20/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "samplesUserLoginViewController.h"
#import "samplesWebAPIConnector.h"
#import "samplesUseViewController.h"
#import "samplesPolicyData.h"
#import "samplesApplicationData.h"

@interface samplesUserLoginViewController ()


@end

@implementation samplesUserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signInPressed:(id)sender {
    
    SamplesApplicationData* appData = [SamplesApplicationData getInstance];
    samplesPolicyData *aPolicy = [[samplesPolicyData alloc]init];
    
    
    aPolicy.policyID = appData.signInPolicyId;
    aPolicy.policyName = @"Sign In";
    
    
    
    [samplesWebAPIConnector doPolicy:aPolicy parent:self completionBlock:^(ADUserInformation* userInfo, NSError* error) {
        if (userInfo)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
            samplesUseViewController* claimsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimsView"];
            claimsController.claims = [NSString stringWithFormat:@" Claims : %@", userInfo.allClaims];
            [self.navigationController pushViewController:claimsController animated:YES];
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

- (IBAction)signUpPressed:(id)sender {
    
    
    SamplesApplicationData* appData = [SamplesApplicationData getInstance];
    samplesPolicyData *aPolicy = [[samplesPolicyData alloc]init];
    
    
    aPolicy.policyID = appData.signUpPolicyId;
    aPolicy.policyName = @"Sign Up";
    
    
    
    [samplesWebAPIConnector doPolicy:aPolicy parent:self completionBlock:^(ADUserInformation* userInfo, NSError* error) {
        if (userInfo)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
            samplesUseViewController* claimsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimsView"];
            claimsController.claims = [NSString stringWithFormat:@" Claims : %@", userInfo.allClaims];
            [self.navigationController pushViewController:claimsController animated:YES];
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
@end
