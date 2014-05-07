//
//  DiceLaunchViewController.m
//  Dice
//
//  Created by Arpan Ghosh on 12/19/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

#import "DiceLaunchViewController.h"


@interface DiceLaunchViewController ()

@property (strong, nonatomic) DiceMainView *mainView;

@end


@implementation DiceLaunchViewController

#pragma mark - Initializers

-(DiceMainView *)mainView{
    return (DiceMainView *)self.view;
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

/*
 When a shake motion is detected on the launch screen, transition to the 
 main view.
 */
-(void)shakeDetected{
   [self performSegueWithIdentifier:DICE_SEGUE_LAUNCH_TO_MAIN sender:self];
}

@end
