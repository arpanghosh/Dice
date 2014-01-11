//
//  DemoCrumbAppLaunchViewController.m
//  DemoIOSAppUsingCrumb
//
//  Created by Arpan Ghosh on 12/19/13.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//

#import "DemoCrumbAppLaunchViewController.h"


@interface DemoCrumbAppLaunchViewController ()

@property (nonatomic, weak) DemoCrumbAppMainViewControllerMainView *mainView;

@end


@implementation DemoCrumbAppLaunchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(DemoCrumbAppMainViewControllerMainView *)mainView{
    return (DemoCrumbAppMainViewControllerMainView *)self.view;
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
