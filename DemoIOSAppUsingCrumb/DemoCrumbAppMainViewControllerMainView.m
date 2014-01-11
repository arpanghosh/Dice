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
