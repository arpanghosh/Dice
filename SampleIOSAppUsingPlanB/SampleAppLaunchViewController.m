//
//  SampleAppLaunchViewController.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/19/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppLaunchViewController.h"


@interface SampleAppLaunchViewController ()

@end


@implementation SampleAppLaunchViewController


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        [self performSegueWithIdentifier:@"LAUNCH_TO_MAIN" sender:self];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self becomeFirstResponder];
}


-(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
          [error localizedDescription],
          [error localizedFailureReason]);
}


@end
