//
//  DiceYelpRecommendation.m
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//

#import "DiceYelpRecommendation.h"

@implementation DiceYelpRecommendation

#pragma mark - Initializers

//Designated Initializer
-(instancetype)initFromAPIResponse:(NSDictionary *)recommendation{
    self = [super init];
    if (self){
        _businessID = [recommendation valueForKey:YELP_ID_KEY];
        _name = [recommendation valueForKey:YELP_NAME_KEY];
        _imageURL = [[recommendation valueForKey:YELP_IMAGE_URL_KEY]
                     stringByReplacingOccurrencesOfString:YELP_SMALL_IMAGE_EXTENSION
                     withString:YELP_LARGE_IMAGE_EXTENSION];
        //_image = nil;
        _yelpURL = [recommendation valueForKey:YELP_MOBILE_PROFILE_URL_KEY];
        _reviewCount = [[recommendation valueForKey:YELP_REVIEW_COUNT_KEY] integerValue];
        _distanceInMiles =
        [[recommendation valueForKey:YELP_DISTANCE_KEY] doubleValue] * METERS_TO_MILES_CONVERSION_FACTOR;
        _ratingImageURL = [recommendation valueForKey:YELP_RATING_IMAGE_URL_KEY];
        //_ratingImage = nil;
        
        //Convert this to a one-line string for ease of diaplay
        _snippetAboutBusiness = [[[recommendation valueForKey:YELP_SNIPPET_TEXT_KEY]
                                  stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        _streetAddress = [[[recommendation valueForKey:YELP_LOCATION_OBJECT_KEY]
                           valueForKey:YELP_ADDRESS_OBJECT_KEY] firstObject] != nil ?
        [[[recommendation valueForKey:YELP_LOCATION_OBJECT_KEY]
          valueForKey:YELP_ADDRESS_OBJECT_KEY] firstObject] : @"";
        
        // Extract all the categories for this recommendation
        NSMutableArray *categoryList = [[NSMutableArray alloc] init];
        for (NSArray *categoryTuple in [recommendation valueForKey:YELP_CATEGORIES_KEY]) {
            [categoryList addObject:[categoryTuple firstObject]];
        }
        _categories = [categoryList componentsJoinedByString:@", "];
        
        /* Extract the street address and the city, state and zip-code components. 
         Ignore everything else */
        _fullAddress = [[[[[recommendation valueForKey:YELP_LOCATION_OBJECT_KEY]
                           valueForKey:YELP_DISPLAY_ADDRESS_KEY] firstObject]
                         stringByAppendingString:@", "]
                        stringByAppendingString:[[[recommendation
                                                   valueForKey:YELP_LOCATION_OBJECT_KEY]
                                                  valueForKey:YELP_DISPLAY_ADDRESS_KEY] lastObject]];
    }
    return self;
}


#pragma mark - Asynchronous Image Download Methods

-(void)downloadBusinessImageIfRequiredAndDisplayInImageView:(UIImageView *)businessImageView{
    [self downloadImagefromURL:_imageURL
orLoadPlaceholderCalled:DICE_RESTAURANT_IMAGE_PLACEHOLDER
         andDisplayInImageView:businessImageView];
}

-(void)downloadRatingImageIfRequiredAndDisplayInImageView:(UIImageView *)ratingImageView{
    [self downloadImagefromURL:_ratingImageURL
       orLoadPlaceholderCalled:DICE_RATING_IMAGE_PLACEHOLDER
         andDisplayInImageView:ratingImageView];
}


-(void)downloadImagefromURL:(NSString *)imageURL
orLoadPlaceholderCalled:(NSString *)placeholder
andDisplayInImageView:(UIImageView *)imageView{
    //Start image fetch in background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *imageData = [NSURLConnection
                             sendSynchronousRequest:[NSURLRequest
                                                     requestWithURL:[NSURL URLWithString:imageURL]]
                             returningResponse:&response
                             error:&error];
        if (!error && ([response statusCode] == kHTTPStatusCodeOK)) {
            [self displayImage:[UIImage imageWithData:imageData] inImageView:imageView];
        }else{
            [self displayImage:[UIImage imageNamed:placeholder] inImageView:imageView];
        }
    });
}

-(void)displayImage:(UIImage *)image inImageView:(UIImageView *)imageView{
    // Update ImageView with fetched image on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.hidden = NO;
        imageView.image = image;
    });
}


@end
