//
//  SampleAppLaunchViewController.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/19/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppLaunchViewController.h"


@interface SampleAppLaunchViewController ()

@property (nonatomic, weak) SampleAppViewControllerMainView *mainView;

@end


@implementation SampleAppLaunchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(SampleAppViewControllerMainView *)mainView{
    return (SampleAppViewControllerMainView *)self.view;
}


-(void)viewWillAppear:(BOOL)animated{
    self.mainView.delegate = self;
    [self.mainView becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self.mainView resignFirstResponder];
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
