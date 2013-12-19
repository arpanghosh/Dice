//
//  SampleAppViewController.m
//  SampleIOSAppUsingPlanB
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "SampleAppViewController.h"





@interface SampleAppViewController ()

@property (nonatomic, strong) SampleAppRandomYelpRecommender *recommender;

@property (weak, nonatomic) IBOutlet UIImageView *recommendationBusinessImage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessCategory;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessReviewCount;
@property (weak, nonatomic) IBOutlet UIImageView *recommendationBusinessRatingImage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessSnippet;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessDistance;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessStreetAddress;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessCrossStreet;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingRecommendation;
@property (weak, nonatomic) IBOutlet UILabel *loadingRecommendationMessage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationError;

@property (strong, nonatomic) UITapGestureRecognizer *imageTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *snippetTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *addressTapGestureRecognizer;
@property (strong, nonatomic) CLGeocoder *geocoder;


@property (strong, nonatomic) SampleAppYelpRecommendation *randomRecommendation;

@end


@implementation SampleAppViewController


-(UITapGestureRecognizer *)imageTapGestureRecognizer{
    if (!_imageTapGestureRecognizer){
        _imageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToImageTap)];
        _imageTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _imageTapGestureRecognizer;
}


-(UITapGestureRecognizer *)snippetTapGestureRecognizer{
    if (!_snippetTapGestureRecognizer){
        _snippetTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSnippetTap)];
        _snippetTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _snippetTapGestureRecognizer;
}


-(UITapGestureRecognizer *)addressTapGestureRecognizer{
    if (!_addressTapGestureRecognizer){
        _addressTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToAddressTap)];
        _addressTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _addressTapGestureRecognizer;
}


-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}


-(void)respondToImageTap{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.randomRecommendation.yelpURL]];
}


-(void)respondToSnippetTap{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.randomRecommendation.yelpURL]];
}


-(void)respondToAddressTap{
    [self.geocoder geocodeAddressString:self.randomRecommendation.fullAddress
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          if (error) {
                              [self logWithMessage:@"Geocoder failed with error" andError:error];
                          }else{
                              if(placemarks && placemarks.count > 0)
                              {
                                  MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:[placemarks firstObject]]];
                                  item.name = self.randomRecommendation.name;
                                  [item openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking}];
                              }
                          }
    }];
    
}


- (void)didGenerateARandomRecommendation:(SampleAppYelpRecommendation *)randomRecommendation{
    self.randomRecommendation = randomRecommendation;
    [self updateViewWithNewRecommendation];
}


-(void)updateViewWithNewRecommendation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingRecommendation stopAnimating];
        self.loadingRecommendationMessage.hidden = YES;
        
        if (self.randomRecommendation) {
            self.recommendationBusinessName.text = self.randomRecommendation.name;
            self.recommendationBusinessName.hidden = NO;
            
            self.recommendationBusinessCategory.text = self.randomRecommendation.categories;
            self.recommendationBusinessCategory.hidden = NO;
            
            self.recommendationBusinessReviewCount.text =
            [NSString stringWithFormat:@"%d reviews",self.randomRecommendation.reviewCount];
            self.recommendationBusinessReviewCount.hidden = NO;
            
            self.recommendationBusinessSnippet.text = self.randomRecommendation.snippet;
            self.recommendationBusinessSnippet.hidden = NO;
            
            self.recommendationBusinessDistance.text =
            [NSString stringWithFormat:@"%.2f miles", self.randomRecommendation.distanceInMiles];
            self.recommendationBusinessDistance.hidden = NO;
            
            
            NSMutableAttributedString *streetAddressString
            = [[NSMutableAttributedString alloc] initWithString:self.randomRecommendation.streetAddress];
            [streetAddressString addAttribute:NSUnderlineStyleAttributeName
                                    value:[NSNumber numberWithInt:1]
                                    range:(NSRange){0,[streetAddressString length]}];
            self.recommendationBusinessStreetAddress.attributedText = streetAddressString;
            self.recommendationBusinessStreetAddress.hidden = NO;
            
            self.recommendationBusinessCrossStreet.text = self.randomRecommendation.crossStreet;
            self.recommendationBusinessCrossStreet.hidden = NO;
            
            [self.randomRecommendation downloadBusinessImageIfRequiredAndDisplayInImageView:self.recommendationBusinessImage];
            [self.randomRecommendation downloadRatingImageIfRequiredAndDisplayInImageView:self.recommendationBusinessRatingImage];
        }else{
            self.recommendationError.hidden = NO;
        }
    });
}


-(void)clearViewElements{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recommendationBusinessName.hidden = YES;
        self.recommendationBusinessCategory.hidden = YES;
        self.recommendationBusinessReviewCount.hidden = YES;
        self.recommendationBusinessSnippet.hidden = YES;
        self.recommendationBusinessDistance.hidden = YES;
        self.recommendationBusinessStreetAddress.hidden = YES;
        self.recommendationBusinessCrossStreet.hidden = YES;
        self.recommendationBusinessImage.hidden = YES;
        self.recommendationBusinessRatingImage.hidden = YES;
        self.recommendationError.hidden = YES;
        
        self.loadingRecommendationMessage.hidden = NO;
        [self.loadingRecommendation startAnimating];
    });
}


- (void)didFailToGenerateRandomRecommendationWithError:(NSError *)error{
    [self logWithMessage:@"Failed to fetch random Yelp recommendation with error" andError:error];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingRecommendation stopAnimating];
        self.loadingRecommendationMessage.hidden = YES;
        self.recommendationError.hidden = NO;
    });
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        [self clearViewElements];
        [self.recommender fetchRandomRecommendation];
    }
}


-(SampleAppRandomYelpRecommender *)recommender{
    if (!_recommender) {
        _recommender = [SampleAppRandomYelpRecommender getRecommender];
        _recommender.delegate = self;
    }
    return _recommender;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeUI];

    [self.recommender fetchRandomRecommendation];

}


-(void) initializeUI{
    [self becomeFirstResponder];
    
    [self clearViewElements];
    [self.recommendationBusinessImage addGestureRecognizer:self.imageTapGestureRecognizer];
    [self.recommendationBusinessSnippet addGestureRecognizer:self.snippetTapGestureRecognizer];
    [self.recommendationBusinessStreetAddress addGestureRecognizer:self.addressTapGestureRecognizer];
}


-(void)logWithMessage:(NSString *)message andError:(NSError *)error{
    NSLog(@"%@ : %@\n%@ : %@", NSStringFromClass([self class]), message,
          [error localizedDescription],
          [error localizedFailureReason]);
}


@end
