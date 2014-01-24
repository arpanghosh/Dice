//
//  DemoCrumbAppMainViewControllerMainView.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/22/13.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//

#import "DemoCrumbAppMainViewControllerMainView.h"

@implementation DemoCrumbAppMainViewControllerMainView

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self.delegate shakeDetected];
    }
}

@end
