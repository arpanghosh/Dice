//
//  DemoCrumbAppYelpRecommendation.h
//  DemoIOSAppUsingCrumb
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//


@interface DemoCrumbAppYelpRecommendation : NSObject

@property (nonatomic, strong) NSString* businessID;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* imageURL;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong, readonly) NSString* yelpURL;
@property (nonatomic, readonly) NSInteger reviewCount;
@property (nonatomic, strong, readonly) NSString* categories;
@property (nonatomic, readonly) double distanceInMiles;
@property (nonatomic, strong, readonly) NSString* ratingImageURL;
@property (nonatomic, strong) UIImage* ratingImage;
@property (nonatomic, readonly, readonly) NSString* fullAddress;
@property (nonatomic, strong, readonly) NSString* streetAddress;
@property (nonatomic, strong, readonly) NSString* snippet;


-(instancetype)initFromAPIResponse:(NSDictionary *)recommendation;
-(void)downloadBusinessImageIfRequiredAndDisplayInImageView:(UIImageView *)businessImageView;
-(void)downloadRatingImageIfRequiredAndDisplayInImageView:(UIImageView *)ratingImageView;

@end
