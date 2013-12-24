//
//  SampleAppRandomYelpRecommender.h
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <stdlib.h>   
#import <OAuthConsumer/OAuthConsumer.h>  

#import "SampleAppYelpRecommendation.h"


typedef enum YelpRequestStates {
   YelpRequestStateUndefined = 0,
    YelpRequestStateStarted,
    YelpRequestStateSuccessful,
    YelpRequestStateFailed
}YelpRequestState;


@protocol SampleAppRandomYelpRecommenderDelegate <NSObject>

-(void)didGenerateARandomRecommendation:(SampleAppYelpRecommendation *)randomRecommendation;

-(void)didFailToGenerateRandomRecommendationWithError:(NSError *)error;

@end




@interface SampleAppRandomYelpRecommender : NSObject <NSURLConnectionDataDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) id <SampleAppRandomYelpRecommenderDelegate> delegate;


+(instancetype)getRecommender;

-(void)fetchRandomRecommendation;

@end
