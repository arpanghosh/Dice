//
//  DiceMainView.m
//  Dice
//
//  Created by Arpan Ghosh on 12/22/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

#import "DiceMainView.h"

@implementation DiceMainView

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    /* Detect a shaking motion of the device, make the device vibrate 
     and notify the controller */
    
    if (motion == UIEventSubtypeMotionShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_delegate shakeDetected];
    }
}

@end
