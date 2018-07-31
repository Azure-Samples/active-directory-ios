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
#import "SamplesAppSettingsController.h"
#import "SamplesApplicationData.h"


@interface SamplesAppSettingsController ()

@property (weak, nonatomic) IBOutlet UITextField *authorityLabel;
@property (weak, nonatomic) IBOutlet UITextField *clientIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *resourceLabel;
@property (weak, nonatomic) IBOutlet UITextField *redirectUriLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fullScreenSwitch;
@property (weak, nonatomic) IBOutlet UITextField *correlationIdLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showClaimsSwitch;
@end

@implementation SamplesAppSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    self->_authorityLabel.text = data.authority;
    self->_clientIdLabel.text = data.clientId;
    self->_resourceLabel.text = data.resourceId;
    self->_redirectUriLabel.text = data.redirectUriString;
    self->_correlationIdLabel.text = data.correlationId;
    [self configureControl:self->_fullScreenSwitch forValue:data.fullScreen];
    [self configureControl:self->_showClaimsSwitch forValue:data.showClaims];
}


- (IBAction)savePressed:(id)sender
{
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    data.authority = self->_authorityLabel.text;
    data.clientId = self->_clientIdLabel.text;
    data.resourceId = self->_resourceLabel.text;
    data.redirectUriString = self->_redirectUriLabel.text;
    data.fullScreen = [self isEnabled:self->_fullScreenSwitch];
    data.correlationId = self->_correlationIdLabel.text;
    data.showClaims = [self isEnabled:self->_showClaimsSwitch];
    [self cancelPressed:sender];
    
}


- (void) configureControl:(UISegmentedControl *)control forValue:(BOOL) enabled
{
    if(enabled){
        [control setSelectedSegmentIndex:1];
    }else
    {
        [control setSelectedSegmentIndex:0];
    }
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clearKeychainPressed:(id)sender
{
   
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    ADKeychainTokenCache* cache = [ADKeychainTokenCache new];
    [cache removeAllForClientId:data.clientId error:nil];
    data.userItem = nil;
    
    // This clears cookies for new sign-in flow. You shouldn't need to do this in your code. You should accept send PROMPT_ALWAYS instead. 
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) isEnabled:(UISegmentedControl *)control
{
    return [control selectedSegmentIndex] != 0;
}

@end
