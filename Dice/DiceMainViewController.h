//
//  DiceMainViewController.h
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//


#import "DiceRandomYelpRecommender.h"
#import "DiceMainView.h"


@interface DiceMainViewController :
UIViewController <DiceRandomYelpRecommenderDelegate, ShakeDetectionDelegate>

@end
