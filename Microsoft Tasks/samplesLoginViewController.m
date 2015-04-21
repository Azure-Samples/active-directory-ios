//
//  samplesLoginViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/21/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "samplesLoginViewController.h"
#import "samplesWebAPIConnector.h"
#import "samplesShowClaimsViewController.h"
#import "samplesPolicyData.h"
#import "samplesApplicationData.h"

@interface samplesLoginViewController ()

@end

@implementation samplesLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    [samplesWebAPIConnector doLogin:YES parent:self completionBlock:^(ADUserInformation* userInfo, NSError* error) {
        if (userInfo && appData.showClaims)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                samplesShowClaimsViewController* claimsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimsView"];
                claimsController.claims = [NSString stringWithFormat:@" Claims : %@", userInfo.allClaims];
                [self.navigationController pushViewController:claimsController animated:YES];
            });
        }
        else if (userInfo)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
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
