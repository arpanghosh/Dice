//
//  DiceRandomYelpRecommender.h
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Trackor Beam. All rights reserved.
//



#import "DiceYelpRecommendation.h"

/* Enum to represent all the possible states that a request to the
 Yelp API could be in */
typedef enum YelpRequestStates {
   YelpRequestStateUndefined = 0,
    YelpRequestStateStarted,
    YelpRequestStateSuccessful,
    YelpRequestStateFailed
}YelpRequestState;


/* Delegate to asynchronously return a fetched Yelp recommendation to a client
 of this recommender. Returns an error if it runs out of recommendations or if it
 was unable to fetch recommendations from the Yelp API
 */
@protocol DiceRandomYelpRecommenderDelegate <NSObject>
@required

-(void)didGenerateARandomRecommendation:(DiceYelpRecommendation *)randomRecommendation;

-(void)didFailToGenerateRandomRecommendationWithError:(NSError *)error;

@end


@interface DiceRandomYelpRecommender :
NSObject <NSURLConnectionDataDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) id<DiceRandomYelpRecommenderDelegate> delegate;

// Returns a singleton instance of the recommender
+(instancetype)getRecommender;

// Asynchronously fetch a recommendation from Yelp
-(void)fetchRandomRecommendation;

@end
