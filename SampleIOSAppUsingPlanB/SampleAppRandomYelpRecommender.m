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

@property (nonatomic) BOOL requestSuccessful;
@property (nonatomic) NSInteger offset;
@property (nonatomic, strong) NSMutableData* requestResponseData;
@property (nonatomic, strong) NSMutableArray* recommendations;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *latestLocation;

@end


@implementation SampleAppRandomYelpRecommender


+(instancetype)getRecommender{
    static SampleAppRandomYelpRecommender *sharedSampleAppRandomYelpRecommender = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSampleAppRandomYelpRecommender = [[self alloc] init];
    });
    return sharedSampleAppRandomYelpRecommender;
}


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
    }
    return self;
}


-(void)prepareForNewAPIRequest{
    _requestResponseData = [NSMutableData data];
    _requestSuccessful = NO;
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
    OAMutableURLRequest *yelpAPIRequest = [self generateYelpAPIRequestBasedOnCurrentLocation];
    [yelpAPIRequest prepare];
    [NSURLConnection connectionWithRequest:yelpAPIRequest delegate:self];
}


-(void)fetchRecommendationsFromYelp{
    [self prepareForNewAPIRequest];
    if (!self.latestLocation ||
        (fabs([self.latestLocation.timestamp timeIntervalSinceNow]) > 300)) {
        self.offset = 0;
        [self.locationManager startUpdatingLocation];
    }else{
        [self createAPIRequestAndFetchData];
    }
}


-(void)fetchRandomRecommendation{
    if ([self.recommendations count] > 0) {
        [self respondToDelegateWithRecommendation:[self dequeueRecommendation]];
    }else{
        [self fetchRecommendationsFromYelp];
    }
}


-(SampleAppYelpRecommendation *)dequeueRecommendation{
    SampleAppYelpRecommendation *recommendation = [self.recommendations lastObject];
    [self.recommendations removeLastObject];
    return recommendation;
}


// CLLocationManager delegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    self.latestLocation = [locations lastObject];
    
    [self createAPIRequestAndFetchData];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self respondToDelegateWithError:error];
}


// NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.requestSuccessful) {
        [self.requestResponseData appendData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self respondToDelegateWithError:error];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.requestSuccessful) {
        NSError *jsonParsingError;
        NSDictionary *deserializedRequestResponseData =
        [NSJSONSerialization JSONObjectWithData:self.requestResponseData
                                        options:kNilOptions
                                          error:&jsonParsingError];
        if (!jsonParsingError) {
            for (NSDictionary *recommendation in [deserializedRequestResponseData valueForKey:@"businesses"]) {
                [self.recommendations addObject:[[SampleAppYelpRecommendation alloc]
                                                 initFromAPIResponse:recommendation]];
            }
            self.offset += [self.recommendations count];
            [self randomizeRecommendations:self.recommendations];
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
        self.requestSuccessful = YES;
    }else{
        [self logWithMessage:[NSString stringWithFormat:@"HTTP request failed with status code %d", [responseHTTP statusCode]] andError:nil];
    }
}


-(void)respondToDelegateWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(didFailToGenerateRandomRecommendationWithError:)]) {
        [self.delegate didFailToGenerateRandomRecommendationWithError:error];
    }else{
        [self logWithMessage:@"No delegate or delegate does not implement didFailToGenerateRandomRecommendationWithError" andError:nil];
    }
}


-(void)respondToDelegateWithRecommendation:(SampleAppYelpRecommendation *)recommendation{
    if ([self.delegate respondsToSelector:@selector(didGenerateARandomRecommendation:)]) {
        [self.delegate didGenerateARandomRecommendation:recommendation];
    }else{
        [self logWithMessage:@"No delegate or delegate does not implement didGenerateARandomRecommendation" andError:nil];
    }
}


-(void)randomizeRecommendations:(NSMutableArray *)recommendations{
    NSUInteger count = [recommendations count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [recommendations exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


-(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
              [error localizedDescription],
          [error localizedFailureReason]);
}


@end
