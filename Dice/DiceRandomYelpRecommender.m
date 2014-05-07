//
//  DiceRandomYelpRecommender.m
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

#import "DiceRandomYelpRecommender.h"

@interface DiceRandomYelpRecommender ()

/*
 Special OAuth consumer & token for using the Yelp API 2.0.
 Yelp requires a weird variant of 2-legged OAuth from a client trying to access it's API.
 The API has no user-centric entities and hence no need for 3-legged OAuth 
 (to obtain a user's access token). However, the API still needs all requests to be 
 signed with the CLIENT's consumer key, consumer secret, token and token secret.
 */
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *token;
@property (nonatomic, strong) id<OASignatureProviding, NSObject> provider;

@property (nonatomic) YelpRequestState requestState;

//Stores the paging offset into the list of fetched recommendations
@property (nonatomic) NSInteger offset;

// Raw Yelp API response data
@property (nonatomic, strong) NSMutableData* requestResponseData;

// Array to store upto 20 recommendations fetched at one time from the Yelp API
@property (nonatomic, strong) NSMutableArray* recommendations;

// LocationManager to fetch the device's current coordinates
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *latestLocation;

// Custom error to return to clients of this recommender
@property (nonatomic, strong) NSError *yelpRequestFailedError;

@end


@implementation DiceRandomYelpRecommender

#pragma mark - Public Methods

// Singleton
+(instancetype)getRecommender{
    static DiceRandomYelpRecommender
    *sharedSampleAppRandomYelpRecommender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSampleAppRandomYelpRecommender = [[self alloc] init];
    });
    return sharedSampleAppRandomYelpRecommender;
}

// Main method for client to request a recommendation
-(void)fetchRandomRecommendation{
    if ([_recommendations count] > 0) {
        [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
    }else{
        [self fetchRecommendationsFromYelp];
    }
}


#pragma mark - DiceRandomYelpRecommenderDelegate Methods

// Delegate method to call on error
-(void)respondToDelegateWithError:(NSError *)error{
    [_delegate didFailToGenerateRandomRecommendationWithError:error];
}

// Delegate method to call on successful recommendation generation
-(void)respondToDelegateWithRecommendation:(DiceYelpRecommendation *)recommendation{
    [_delegate didGenerateARandomRecommendation:recommendation];
}


#pragma mark - Initializers

-(instancetype)init{
    self = [super init];
    if (self){
        
        // Initialize OAuth consumer with authentication stuff
        _consumer =
        [[OAConsumer alloc] initWithKey:DICE_YELP_CONSUMER_KEY
                                 secret:DICE_YELP_CONSUMER_SECRET];
        _token =
        [[OAToken alloc] initWithKey:DICE_YELP_API_TOKEN
                              secret:DICE_YELP_API_TOKEN_SECRET];
        _provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
        
        // Initializing the location manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        
        _latestLocation = nil;

        // Empty array to store fetched recommendations
        _recommendations = [[NSMutableArray alloc] init];
        
        _requestState = YelpRequestStateUndefined;
    }
    return self;
}


// Lazy getter for custom error to return to client
-(NSError *)yelpRequestFailedError{
    if (!_yelpRequestFailedError){
        NSDictionary* errorDetails =
        @{NSLocalizedDescriptionKey :
              @"HTTP request not successful.",
          NSLocalizedFailureReasonErrorKey :
              @"The web service is down or the URL is incorrect."};
        _yelpRequestFailedError =
        [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                            code:kHTTPStatusCodeNotFound
                        userInfo:errorDetails];
    }
    return _yelpRequestFailedError;
}


#pragma mark - Yelp API Request/Response Functionality

-(void)resetStateBeforeNewAPIRequest{
    _requestResponseData = [NSMutableData data];
    _requestState = YelpRequestStateUndefined;
}


// Generate a Yelp API URLRequest
-(OAMutableURLRequest *)generateYelpAPIRequestBasedOnCurrentLocation{
    return ([[OAMutableURLRequest alloc]
             initWithURL:[self yelpAPIURLWithCurrentLocation]
             consumer:_consumer
             token:_token
             realm:nil
             signatureProvider:_provider]);
}


/* Generate the correct Yelp API URL string  with the user's coordinates as 
 encoded as parameters */
-(NSURL *)yelpAPIURLWithCurrentLocation{
    NSString *URLString =
    [NSString stringWithFormat:DICE_YELP_API_REQUEST_URL_TEMPLATE,
     _latestLocation.coordinate.latitude,
     _latestLocation.coordinate.longitude,
     (long)_offset];
    return [[NSURL alloc] initWithString:URLString];
}


/* Make the REST call to the Yelp API */
-(void)createAPIRequestAndFetchData{
    if (_requestState != YelpRequestStateStarted) {
        OAMutableURLRequest *yelpAPIRequest =
        [self generateYelpAPIRequestBasedOnCurrentLocation];
        [yelpAPIRequest prepare];
        _requestState = YelpRequestStateStarted;
        [NSURLConnection connectionWithRequest:yelpAPIRequest
                                      delegate:self];
    }
}

/*If user's location is stale, fetch their current location. Otherwise
 go ahead and fetch Yelp recommendations using the available location */
-(void)fetchRecommendationsFromYelp{
    [self resetStateBeforeNewAPIRequest];
    if (!_latestLocation ||
        (fabs([_latestLocation.timestamp timeIntervalSinceNow]) >
         DICE_LOCATION_TIMEOUT_IN_SECONDS)) {
        _offset = 0;
        [_locationManager startUpdatingLocation];
    }else{
        [self createAPIRequestAndFetchData];
    }
}


#pragma mark - Yelp Recommendation Data Processing

-(DiceYelpRecommendation *)dequeueRecommendation{
    DiceYelpRecommendation *recommendation =
    [_recommendations lastObject];
    [_recommendations removeLastObject];
    return recommendation;
}


// Shuffle array of fetched recommendations for randomness
-(void)randomizeRecommendations{
    NSUInteger count = [_recommendations count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger n = arc4random_uniform((u_int32_t)(count - i)) + i;
        [_recommendations exchangeObjectAtIndex:i
                                  withObjectAtIndex:n];
    }
}


-(void)populateRecommendationsFromJSON:(NSDictionary *)deserializedRequestResponseData{
    for (NSDictionary *recommendation in
         [deserializedRequestResponseData valueForKey:DICE_YELP_API_RESPONSE_ROOT_FIELD]) {
        [_recommendations addObject:[[DiceYelpRecommendation alloc]
                                         initFromAPIResponse:recommendation]];
    }
    _offset += [_recommendations count];
    [self randomizeRecommendations];
}


#pragma mark - CLLocationManagerDelegate Methods

//Fetch recommendations from Yelp based on a fresh location update
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    _latestLocation = [locations lastObject];
    
    [self createAPIRequestAndFetchData];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self respondToDelegateWithError:error];
}


#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_requestState == YelpRequestStateSuccessful) {
        [_requestResponseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _requestState = YelpRequestStateFailed;
    [self respondToDelegateWithError:error];
}

//Parse JSON response from Yelp and instantiate a Recommendation objects
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (_requestState == YelpRequestStateSuccessful) {
        NSError *jsonParsingError;
        NSDictionary *deserializedRequestResponseData =
        [NSJSONSerialization JSONObjectWithData:_requestResponseData
                                        options:kNilOptions
                                          error:&jsonParsingError];
        if (!jsonParsingError) {
            [self populateRecommendationsFromJSON:deserializedRequestResponseData];
            [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
        }else{
            _requestState = YelpRequestStateFailed;
            [self respondToDelegateWithError:jsonParsingError];
        }
    }else{
        [self respondToDelegateWithError:self.yelpRequestFailedError];
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *responseHTTP = (NSHTTPURLResponse *)response;
    if ([responseHTTP statusCode] == kHTTPStatusCodeOK) {
        _requestState = YelpRequestStateSuccessful;
    }else{
        _requestState = YelpRequestStateFailed;
        [self respondToDelegateWithError:self.yelpRequestFailedError];
    }
}

@end
