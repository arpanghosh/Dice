//
//  DiceYelpRecommendation.h
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Redeye. All rights reserved.
//


@interface DiceYelpRecommendation : NSObject

@property (nonatomic, strong) NSString* businessID;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* imageURL;
//@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong, readonly) NSString* yelpURL;
@property (nonatomic, readonly) NSInteger reviewCount;
@property (nonatomic, strong, readonly) NSString* categories;
@property (nonatomic, readonly) double distanceInMiles;
@property (nonatomic, strong, readonly) NSString* ratingImageURL;
//@property (nonatomic, strong) UIImage* ratingImage;
@property (nonatomic, readonly, readonly) NSString* fullAddress;
@property (nonatomic, strong, readonly) NSString* streetAddress;
@property (nonatomic, strong, readonly) NSString* snippetAboutBusiness;


//Designated Initializer
-(instancetype)initFromAPIResponse:(NSDictionary *)recommendation;

/* Methods for downloading the restaurant image and ratings image for this recommendation
    asynchronously in the background*/
-(void)downloadBusinessImageIfRequiredAndDisplayInImageView:(UIImageView *)businessImageView;

-(void)downloadRatingImageIfRequiredAndDisplayInImageView:(UIImageView *)ratingImageView;

@end
