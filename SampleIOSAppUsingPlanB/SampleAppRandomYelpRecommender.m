//
//  SampleAppRandomYelpRecommender.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppRandomYelpRecommender.h"

@interface SampleAppRandomYelpRecommender ()

@property (nonatomic, strong, readonly) NSString *apiConsumerKey;
@property (nonatomic, strong, readonly) NSString *apiConsumerSecret;
@property (nonatomic, strong, readonly) NSString *apiToken;
@property (nonatomic, strong, readonly) NSString *apiTokenSecret;

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *token;
@property (nonatomic, strong) id<OASignatureProviding, NSObject> provider;

@property (nonatomic) YelpRequestState requestState;
@property (nonatomic) NSInteger offset;
@property (nonatomic, strong) NSMutableData* requestResponseData;
@property (nonatomic, strong) NSMutableArray* recommendations;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *latestLocation;

@end


@implementation SampleAppRandomYelpRecommender

// Publicly visible methods
/************************************************************************************************************/

// Singleton
+(instancetype)getRecommender{
    static SampleAppRandomYelpRecommender *sharedSampleAppRandomYelpRecommender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSampleAppRandomYelpRecommender = [[self alloc] init];
    });
    return sharedSampleAppRandomYelpRecommender;
}


// Internal initializer
-(instancetype)init{
    self = [super init];
    if (self){
        _apiConsumerKey = @"Uern3Sirc7UqgQ9cl_d2Kg";
        _apiConsumerSecret = @"gG_0G9lovVTG2Sd4ZTLmag55KJY";
        _apiToken = @"OWyYIafAtafVTi8a12RvXbXJfdnbhPZB";
        _apiTokenSecret = @"zvlHSLDDJqUKNR5wG220SoVvp3A";
        
        _consumer = [[OAConsumer alloc] initWithKey:_apiConsumerKey
                                             secret:_apiConsumerSecret];
        _token = [[OAToken alloc] initWithKey:_apiToken secret:_apiTokenSecret];
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


// Main method for client to request a recommendation
-(void)fetchRandomRecommendation{
    if ([self.recommendations count] > 0) {
        [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
    }else{
        [self fetchRecommendationsFromYelp];
    }
}

// Delegate method to call on error
-(void)respondToDelegateWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(didFailToGenerateRandomRecommendationWithError:)]) {
        [self.delegate didFailToGenerateRandomRecommendationWithError:error];
    }else{
        [self logWithMessage:@"No delegate or delegate does not implement didFailToGenerateRandomRecommendationWithError" andError:nil];
    }
}


// Delegate method to call on successful recommendation generation
-(void)respondToDelegateWithRecommendation:(SampleAppYelpRecommendation *)recommendation{
    if ([self.delegate respondsToSelector:@selector(didGenerateARandomRecommendation:)]) {
        [self.delegate didGenerateARandomRecommendation:recommendation];
    }else{
        [self logWithMessage:@"No delegate or delegate does not implement didGenerateARandomRecommendation" andError:nil];
    }
}

/*********************************************************************************************************************/




// Methods dealing with the Yelp API
/*********************************************************************************************************************/

-(void)resetStateBeforeNewAPIRequest{
    _requestResponseData = [NSMutableData data];
    _requestState = YelpRequestStateUndefined;
}


-(OAMutableURLRequest *)generateYelpAPIRequestBasedOnCurrentLocation{
    return ([[OAMutableURLRequest alloc] initWithURL:[self yelpAPIURLWithCurrentLocation]
                                                      consumer:self.consumer
                                                         token:self.token
                                                         realm:nil
                                             signatureProvider:self.provider]);
}


-(NSURL *)yelpAPIURLWithCurrentLocation{
    NSString *URLString =
    [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurants&ll=%f,%f&radius_filter=3219&offset=%d",
     self.latestLocation.coordinate.latitude, self.latestLocation.coordinate.longitude, self.offset];
    return [[NSURL alloc] initWithString:URLString];
}


-(void)createAPIRequestAndFetchData{
    if (self.requestState != YelpRequestStateStarted) {
        OAMutableURLRequest *yelpAPIRequest = [self generateYelpAPIRequestBasedOnCurrentLocation];
        [yelpAPIRequest prepare];
        self.requestState = YelpRequestStateStarted;
        [NSURLConnection connectionWithRequest:yelpAPIRequest delegate:self];
    }
}


-(void)fetchRecommendationsFromYelp{
    [self resetStateBeforeNewAPIRequest];
    if (!self.latestLocation ||
        (fabs([self.latestLocation.timestamp timeIntervalSinceNow]) > 600)) {
        self.offset = 0;
        [self.locationManager startUpdatingLocation];
    }else{
        [self createAPIRequestAndFetchData];
    }
}

/******************************************************************************************************************/



// Methods to handle and randomize Yelp recommendations
/******************************************************************************************************************/

-(SampleAppYelpRecommendation *)dequeueRecommendation{
    SampleAppYelpRecommendation *recommendation = [self.recommendations lastObject];
    [self.recommendations removeLastObject];
    return recommendation;
}


-(void)randomizeRecommendations{
    NSUInteger count = [self.recommendations count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [self.recommendations exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


-(void)populateRecommendationsFromJSON:(NSDictionary *)deserializedRequestResponseData{
    for (NSDictionary *recommendation in [deserializedRequestResponseData valueForKey:@"businesses"]) {
        [self.recommendations addObject:[[SampleAppYelpRecommendation alloc]
                                         initFromAPIResponse:recommendation]];
    }
    self.offset += [self.recommendations count];
    [self randomizeRecommendations];
}

/*******************************************************************************************************************/



// CLLocationManager delegate methods
/*******************************************************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    self.latestLocation = [locations lastObject];
    
    [self createAPIRequestAndFetchData];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self respondToDelegateWithError:error];
}

/*****************************************************************************************************************/




// NSURLConnection delegate methods
/*****************************************************************************************************************/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.requestState == YelpRequestStateSuccessful) {
        [self.requestResponseData appendData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self respondToDelegateWithError:error];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.requestState == YelpRequestStateSuccessful) {
        NSError *jsonParsingError;
        NSDictionary *deserializedRequestResponseData =
        [NSJSONSerialization JSONObjectWithData:self.requestResponseData
                                        options:kNilOptions
                                          error:&jsonParsingError];
        //NSLog(@"%@", [NSString stringWithUTF8String:[self.requestResponseData bytes]]);
        if (!jsonParsingError) {
            [self populateRecommendationsFromJSON:deserializedRequestResponseData];
            [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
        }else{
            [self respondToDelegateWithError:jsonParsingError];
        }
    }else{
        NSDictionary* errorDetails =
  @{NSLocalizedDescriptionKey : @"HTTP request not successful.",
    NSLocalizedFailureReasonErrorKey : @"The web service is down or the URL is incorrect."};
        [self respondToDelegateWithError:[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                             code:404
                                                         userInfo:errorDetails]];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *responseHTTP = (NSHTTPURLResponse *)response;
    if ([responseHTTP statusCode] == 200) {
        self.requestState = YelpRequestStateSuccessful;
    }else{
        self.requestState = YelpRequestStateFailed;
        [self logWithMessage:[NSString stringWithFormat:@"HTTP request failed with status code %d", [responseHTTP statusCode]] andError:nil];
    }
}

/*********************************************************************************************************************/




// Logging convenience method
-(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
              [error localizedDescription],
          [error localizedFailureReason]);
}


@end
