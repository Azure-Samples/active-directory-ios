#import "SamplesAppSettingsController.h"
#import "SamplesApplicationData.h"
#import <ADALiOS/ADAL.h>

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
    id<ADTokenCacheStoring> cache = [ADAuthenticationSettings sharedInstance].defaultTokenCacheStore;
    [cache removeAllWithError:nil];
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    data.userItem = nil;
    
    // This clears cookies for new sign-in flow. We shouldn't need to do this. Server should accept PROMPT_ALWAYS
    
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