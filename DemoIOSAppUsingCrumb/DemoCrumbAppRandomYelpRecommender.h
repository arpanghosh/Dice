//
//  DemoCrumbAppRandomYelpRecommender.h
//  DemoIOSAppUsingCrumb
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Trackor Beam. All rights reserved.
//



#import "DemoCrumbAppYelpRecommendation.h"


typedef enum YelpRequestStates {
   YelpRequestStateUndefined = 0,
    YelpRequestStateStarted,
    YelpRequestStateSuccessful,
    YelpRequestStateFailed
}YelpRequestState;


@protocol DemoCrumbAppRandomYelpRecommenderDelegate <NSObject>

-(void)didGenerateARandomRecommendation:(DemoCrumbAppYelpRecommendation *)randomRecommendation;

-(void)didFailToGenerateRandomRecommendationWithError:(NSError *)error;

@end




@interface DemoCrumbAppRandomYelpRecommender : NSObject <NSURLConnectionDataDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) id <DemoCrumbAppRandomYelpRecommenderDelegate> delegate;


+(instancetype)getRecommender;

-(void)fetchRandomRecommendation;

@end
