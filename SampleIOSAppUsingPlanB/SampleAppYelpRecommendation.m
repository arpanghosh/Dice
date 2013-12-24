//
//  SampleAppYelpRecommendation.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppYelpRecommendation.h"


@interface SampleAppYelpRecommendation()

@end


@implementation SampleAppYelpRecommendation

-(instancetype)initFromAPIResponse:(NSDictionary *)recommendation{
    self = [super init];
    if (self){
        _businessID = [recommendation valueForKey:@"id"];
        _name = [recommendation valueForKey:@"name"];
        _imageURL = [[recommendation valueForKey:@"image_url"]
                     stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
        _image = nil;
        _yelpURL = [recommendation valueForKey:@"mobile_url"];
        _reviewCount = [[recommendation valueForKey:@"review_count"] integerValue];
        _distanceInMiles =
        [[recommendation valueForKey:@"review_count"] doubleValue] * 0.000621371;
        _ratingImageURL = [recommendation valueForKey:@"rating_img_url_large"];
        _ratingImage = nil;
        _snippet = [[[recommendation valueForKey:@"snippet_text"] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        _streetAddress = [[[recommendation valueForKey:@"location"] valueForKey:@"address"] firstObject] != nil ? [[[recommendation valueForKey:@"location"] valueForKey:@"address"] firstObject] : @"";
        
        NSMutableArray *categoryList = [[NSMutableArray alloc] init];
        for (NSArray *categoryTuple in [recommendation valueForKey:@"categories"]) {
            [categoryList addObject:[categoryTuple firstObject]];
        }
        _categories = [categoryList componentsJoinedByString:@", "];
        
        _fullAddress = [[[[[recommendation valueForKey:@"location"] valueForKey:@"display_address"] firstObject]
                         stringByAppendingString:@", "] stringByAppendingString:[[[recommendation
                                                   valueForKey:@"location"] valueForKey:@"display_address"] lastObject]];
        
    }
    return self;
}


-(void)downloadBusinessImageIfRequiredAndDisplayInImageView:(UIImageView *)businessImageView{
    if (!_image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection
                                 sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]]
                                 returningResponse:&response
                                 error:&error];
            if (!error && ([response statusCode] == 200)) {
                _image = [UIImage imageWithData:imageData];
            }else{
                _image = [UIImage imageNamed:@"image_not_available.png"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                businessImageView.hidden = NO;
                businessImageView.image = _image;
            });
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            businessImageView.hidden = NO;
            businessImageView.image = _image;
        });
    }
}


-(void)downloadRatingImageIfRequiredAndDisplayInImageView:(UIImageView *)ratingImageView{
    if (!_ratingImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection
                                 sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.ratingImageURL]]
                                 returningResponse:&response
                                 error:&error];
            if (!error && ([response statusCode] == 200)) {
                _ratingImage = [UIImage imageWithData:imageData];
            }else{
                _ratingImage = [UIImage imageNamed:@"image_not_available_small.png"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                ratingImageView.hidden = NO;
                ratingImageView.image = _ratingImage;
            });
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            ratingImageView.hidden = NO;
            ratingImageView.image = _ratingImage;
        });
    }
}


@end
