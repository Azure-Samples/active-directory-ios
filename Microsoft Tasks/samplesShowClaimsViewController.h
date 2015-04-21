//
//  samplesShowClaimsViewController.h
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/21/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface samplesShowClaimsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *useLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *tokenView;
@property (weak, nonatomic) IBOutlet UITextView *tokenText;
@property (nonatomic, strong) NSString *claims;
- (IBAction)homePressed:(id)sender;

@end
