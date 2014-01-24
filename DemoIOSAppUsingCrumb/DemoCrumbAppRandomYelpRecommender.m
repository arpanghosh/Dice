//
//  DemoCrumbAppRandomYelpRecommender.m
//  DemoIOSAppUsingCrumb
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//

#import "DemoCrumbAppRandomYelpRecommender.h"

@interface DemoCrumbAppRandomYelpRecommender ()

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *token;
@property (nonatomic, strong) id<OASignatureProviding, NSObject> provider;

@property (nonatomic) YelpRequestState requestState;
@property (nonatomic) NSInteger offset;
@property (nonatomic, strong) NSMutableData* requestResponseData;
@property (nonatomic, strong) NSMutableArray* recommendations;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *latestLocation;

@property (nonatomic, strong) NSError *yelpRequestFailedError;

@end


@implementation DemoCrumbAppRandomYelpRecommender

#pragma mark - Public Methods

// Singleton
+(instancetype)getRecommender{
    static DemoCrumbAppRandomYelpRecommender
    *sharedSampleAppRandomYelpRecommender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSampleAppRandomYelpRecommender = [[self alloc] init];
    });
    return sharedSampleAppRandomYelpRecommender;
}

// Main method for client to request a recommendation
-(void)fetchRandomRecommendation{
    if ([self.recommendations count] > 0) {
        [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
    }else{
        [self fetchRecommendationsFromYelp];
    }
}


#pragma mark - DemoCrumbAppRandomYelpRecommenderDelegate Methods

// Delegate method to call on error
-(void)respondToDelegateWithError:(NSError *)error{
    [self.delegate didFailToGenerateRandomRecommendationWithError:error];
}

// Delegate method to call on successful recommendation generation
-(void)respondToDelegateWithRecommendation:(DemoCrumbAppYelpRecommendation *)recommendation{
    [self.delegate didGenerateARandomRecommendation:recommendation];
}


#pragma mark - Initializers

-(instancetype)init{
    self = [super init];
    if (self){
        _consumer =
        [[OAConsumer alloc] initWithKey:DEMO_CRUMB_APP_YELP_CONSUMER_KEY
                                 secret:DEMO_CRUMB_APP_YELP_CONSUMER_SECRET];
        _token =
        [[OAToken alloc] initWithKey:DEMO_CRUMB_APP_YELP_API_TOKEN
                              secret:DEMO_CRUMB_APP_YELP_API_TOKEN_SECRET];
        _provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _latestLocation = nil;
        _recommendations = [[NSMutableArray alloc] init];
        _requestState = YelpRequestStateUndefined;
    }
    return self;
}

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

-(OAMutableURLRequest *)generateYelpAPIRequestBasedOnCurrentLocation{
    return ([[OAMutableURLRequest alloc]
             initWithURL:[self yelpAPIURLWithCurrentLocation]
             consumer:self.consumer
             token:self.token
             realm:nil
             signatureProvider:self.provider]);
}

-(NSURL *)yelpAPIURLWithCurrentLocation{
    NSString *URLString =
    [NSString stringWithFormat:DEMO_CRUMB_APP_YELP_API_REQUEST_URL,
     self.latestLocation.coordinate.latitude,
     self.latestLocation.coordinate.longitude,
     (long)self.offset];
    return [[NSURL alloc] initWithString:URLString];
}

-(void)createAPIRequestAndFetchData{
    if (self.requestState != YelpRequestStateStarted) {
        OAMutableURLRequest *yelpAPIRequest =
        [self generateYelpAPIRequestBasedOnCurrentLocation];
        [yelpAPIRequest prepare];
        self.requestState = YelpRequestStateStarted;
        [NSURLConnection connectionWithRequest:yelpAPIRequest
                                      delegate:self];
    }
}

-(void)fetchRecommendationsFromYelp{
    [self resetStateBeforeNewAPIRequest];
    if (!self.latestLocation ||
        (fabs([self.latestLocation.timestamp timeIntervalSinceNow]) >
         DEMO_CRUMB_APP_LOCATION_TIMEOUT_IN_SECONDS)) {
        self.offset = 0;
        [self.locationManager startUpdatingLocation];
    }else{
        [self createAPIRequestAndFetchData];
    }
}


#pragma mark - Yelp Recommendation Data Processing

-(DemoCrumbAppYelpRecommendation *)dequeueRecommendation{
    DemoCrumbAppYelpRecommendation *recommendation =
    [self.recommendations lastObject];
    [self.recommendations removeLastObject];
    return recommendation;
}

-(void)randomizeRecommendations{
    NSUInteger count = [self.recommendations count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((u_int32_t)nElements) + i;
        [self.recommendations exchangeObjectAtIndex:i
                                  withObjectAtIndex:n];
    }
}

-(void)populateRecommendationsFromJSON:(NSDictionary *)deserializedRequestResponseData{
    for (NSDictionary *recommendation in [deserializedRequestResponseData valueForKey:DEMO_CRUMB_APP_YELP_API_RESPONSE_ROOT_FIELD]) {
        [self.recommendations addObject:[[DemoCrumbAppYelpRecommendation alloc]
                                         initFromAPIResponse:recommendation]];
    }
    self.offset += [self.recommendations count];
    [self randomizeRecommendations];
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    self.latestLocation = [locations lastObject];
    
    [self createAPIRequestAndFetchData];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [self respondToDelegateWithError:error];
}


#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.requestState == YelpRequestStateSuccessful) {
        [self.requestResponseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.requestState = YelpRequestStateFailed;
    [self respondToDelegateWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.requestState == YelpRequestStateSuccessful) {
        NSError *jsonParsingError;
        NSDictionary *deserializedRequestResponseData =
        [NSJSONSerialization JSONObjectWithData:self.requestResponseData
                                        options:kNilOptions
                                          error:&jsonParsingError];
        if (!jsonParsingError) {
            [self populateRecommendationsFromJSON:deserializedRequestResponseData];
            [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
        }else{
            self.requestState = YelpRequestStateFailed;
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
        self.requestState = YelpRequestStateSuccessful;
    }else{
        self.requestState = YelpRequestStateFailed;
        [self respondToDelegateWithError:self.yelpRequestFailedError];
    }
}

@end
