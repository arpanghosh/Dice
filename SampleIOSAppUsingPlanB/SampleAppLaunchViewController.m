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


- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated{
    SampleAppViewControllerMainView *mainView = (SampleAppViewControllerMainView *)self.view;
    mainView.delegate = self;
    [mainView becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated{
    SampleAppViewControllerMainView *mainView = (SampleAppViewControllerMainView *)self.view;
    [mainView resignFirstResponder];
}


-(void)shakeDetected{
   [self performSegueWithIdentifier:@"LAUNCH_TO_MAIN" sender:self];
}


-(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
          [error localizedDescription],
          [error localizedFailureReason]);
}


@end
