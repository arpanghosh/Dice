//
//  SampleAppViewControllerMainView.h
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/22/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>

@protocol SampleAppViewControllerMainViewDelegate

-(void)shakeDetected;

@end



@interface SampleAppViewControllerMainView : UIView

@property (nonatomic, weak) id <SampleAppViewControllerMainViewDelegate> delegate;

@end
