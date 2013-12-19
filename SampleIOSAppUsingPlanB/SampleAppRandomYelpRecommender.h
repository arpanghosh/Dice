//
//  SampleAppRandomYelpRecommender.h
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <stdlib.h>   

#import "OAuthConsumer.h"
#import "SampleAppYelpRecommendation.h"


@protocol SampleAppRandomYelpRecommenderDelegate <NSObject>

-(void)didGenerateARandomRecommendation:(SampleAppYelpRecommendation *)randomRecommendation;

-(void)didFailToGenerateRandomRecommendationWithError:(NSError *)error;

@end




@interface SampleAppRandomYelpRecommender : NSObject <NSURLConnectionDataDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) id <SampleAppRandomYelpRecommenderDelegate> delegate;


+(instancetype)getRecommender;

-(void)fetchRandomRecommendation;

@end
