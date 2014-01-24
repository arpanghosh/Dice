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

#pragma mark - Initializers

-(DemoCrumbAppMainViewControllerMainView *)mainView{
    return (DemoCrumbAppMainViewControllerMainView *)self.view;
}


#pragma mark - ViewController Lifecycle Methods

-(void)viewWillAppear:(BOOL)animated{
    self.mainView.delegate = self;
    [self.mainView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.mainView resignFirstResponder];
}


#pragma mark - ShakeDetectionDelegate Methods

-(void)shakeDetected{
   [self performSegueWithIdentifier:DEMO_CRUMB_APP_SEGUE_LAUNCH_TO_MAIN sender:self];
}

@end
