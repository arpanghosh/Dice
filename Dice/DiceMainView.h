//
//  DiceMainView.h
//  Dice
//
//  Created by Arpan Ghosh on 12/22/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//


/* A delegate for controllers including this view to implement so 
 that they can respond to a 'shake' event.
 */
@protocol ShakeDetectionDelegate

-(void)shakeDetected;

@end


/* A container view which is the first responder for 'shake' motion
 events. It makes the phone vibrate and notifies the controller of the 
 'shake' motion so that it can respond appropriately.
 */

@interface DiceMainView : UIView

@property (nonatomic, weak) id <ShakeDetectionDelegate> delegate;

@end

