//
//  SampleAppViewControllerMainView.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/22/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppViewControllerMainView.h"

@implementation SampleAppViewControllerMainView


-(BOOL)canBecomeFirstResponder{
    return YES;
}


-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self.delegate shakeDetected];
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
