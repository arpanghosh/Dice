//
//  SampleAppViewController.h
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SampleAppRandomYelpRecommender.h"
#import "SampleAppViewControllerMainView.h"


@interface SampleAppViewController : UIViewController <SampleAppRandomYelpRecommenderDelegate, SampleAppViewControllerMainViewDelegate>

@end
