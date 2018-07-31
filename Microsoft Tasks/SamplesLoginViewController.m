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
#import "SamplesLoginViewController.h"
#import "SamplesWebAPIConnector.h"
#import "SamplesShowClaimsViewController.h"
#import "SamplesPolicyData.h"
#import "SamplesApplicationData.h"

@interface SamplesLoginViewController ()

@end

@implementation SamplesLoginViewController

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
    
    [SamplesWebAPIConnector doLogin:YES parent:self completionBlock:^(ADUserInformation* userInfo, NSError* error) {
        if (userInfo && appData.showClaims)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                SamplesShowClaimsViewController* claimsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimsView"];
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
