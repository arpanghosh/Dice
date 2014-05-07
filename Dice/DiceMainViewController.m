//
//  DiceMainViewController.m
//  Dice
//
//  Created by Arpan Ghosh on 12/17/13.
//  Copyright (c) 2014 TracktorBeam. All rights reserved.
//

#import "DiceMainViewController.h"


@interface DiceMainViewController ()

@property (nonatomic, strong) DiceRandomYelpRecommender *recommender;


//Outlets to UI elements
@property (weak, nonatomic) IBOutlet UIImageView *recommendationBusinessImage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessCategory;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessReviewCount;
@property (weak, nonatomic) IBOutlet UIImageView *recommendationBusinessRatingImage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessSnippet;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessDistance;
@property (weak, nonatomic) IBOutlet UILabel *recommendationBusinessStreetAddress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingRecommendation;
@property (weak, nonatomic) IBOutlet UILabel *loadingRecommendationMessage;
@property (weak, nonatomic) IBOutlet UILabel *recommendationError;
@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (weak, nonatomic) IBOutlet UIButton *cancelTutorialView;
@property (weak, nonatomic) DiceMainView *mainView;

//Gesture recognizers for the various actions the user can perform on this view
@property (strong, nonatomic) UITapGestureRecognizer *imageTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *snippetTapGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *addressTapGestureRecognizer;

//Instance of geocoder to convert street address into lat, long
@property (strong, nonatomic) CLGeocoder *geocoder;

@property (strong, nonatomic) DiceYelpRecommendation *randomRecommendation;

@property (nonatomic) BOOL isFirstAppLaunch;

@end


@implementation DiceMainViewController

#pragma mark - Yelp Tap Gesture Handling & Display Methods

//Register a tap on the image of the restaurant
-(UITapGestureRecognizer *)imageTapGestureRecognizer{
    if (!_imageTapGestureRecognizer){
        _imageTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(openBusinessPageinYelp)];
        _imageTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _imageTapGestureRecognizer;
}

//Register a tap on the displayed recommendation snippet
-(UITapGestureRecognizer *)snippetTapGestureRecognizer{
    if (!_snippetTapGestureRecognizer){
        _snippetTapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(openBusinessPageinYelp)];
        _snippetTapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _snippetTapGestureRecognizer;
}

//View the current recommendation in the Yelp App or Yelp mobile site
-(void)openBusinessPageinYelp{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:YELP_APP_URL_FORMAT]]) {
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:[NSString stringWithFormat:DICE_YELP_APP_BUSINESS_PAGE_URL_TEMPLATE,
                                       _randomRecommendation.businessID]]];
    }else{
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:_randomRecommendation.yelpURL]];
    }
}


#pragma mark - Map Tap Gesture Handling & Display Methods

//Register a tap on the displayed address
-(UITapGestureRecognizer *)addressTapGestureRecognizer{
    if (!_addressTapGestureRecognizer){
        _addressTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(respondToAddressTap)];
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


/*Convert street address into lat, long. Open the default map app and display directions
from current location to the restaurant */
-(void)respondToAddressTap{
    [self.geocoder geocodeAddressString:_randomRecommendation.fullAddress
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          if (error) {
                              [DiceLogger logWithClass:[self class]
                                                       Message:@"Geocoder failed with error"
                                                      andError:error];
                          }else{
                              if(placemarks && placemarks.count > 0)
                              {
                                  MKMapItem *item = [[MKMapItem alloc]
                                                     initWithPlacemark:[[MKPlacemark alloc]
                                                                        initWithPlacemark:[placemarks firstObject]]];
                                  item.name = _randomRecommendation.name;
                                  [item openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey :
                                                                          MKLaunchOptionsDirectionsModeWalking}];
                              }
                          }
    }];
}


#pragma mark - Initializers, Getters & Setters

-(DiceRandomYelpRecommender *)recommender{
    if (!_recommender) {
        _recommender = [DiceRandomYelpRecommender getRecommender];
        _recommender.delegate = self;
    }
    return _recommender;
}

-(DiceMainView *)mainView{
    return (DiceMainView *)self.view;
}

// Initialize everything for this ViewController
-(void)initialize{
    _isFirstAppLaunch = [self firstAppLaunch];
    
    [self initializeGestureRecognizers];
    [self initializeUIElements];
    
    //Fetch the first recommendation
    [self updateViewWhileFetchingRecommendation];
    [self.recommender fetchRandomRecommendation];
}

-(void)initializeUIElements{
    dispatch_async(dispatch_get_main_queue(), ^{
        _recommendationBusinessReviewCount.layer.cornerRadius = 4;
        _recommendationBusinessStreetAddress.layer.cornerRadius = 4;
        _recommendationBusinessDistance.layer.cornerRadius = 4;
        
        [_tutorialView setHidden:YES];
        _tutorialView.backgroundColor =
        [UIColor colorWithWhite:0.0f alpha:0.8f];
    });
}

-(void) initializeGestureRecognizers{
    [_recommendationBusinessImage
     addGestureRecognizer:self.imageTapGestureRecognizer];
    [_recommendationBusinessSnippet
     addGestureRecognizer:self.snippetTapGestureRecognizer];
    [_recommendationBusinessStreetAddress
     addGestureRecognizer:self.addressTapGestureRecognizer];
}


#pragma mark - DiceRandomYelpRecommenderDelegate Methods

- (void)didGenerateARandomRecommendation:(DiceYelpRecommendation *)randomRecommendation{
    _randomRecommendation = randomRecommendation;
    if (_randomRecommendation) {
        
        /*Show a tutorial overlay on top of the view if this is 
         the first time ever launching the app*/
        if (_isFirstAppLaunch) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tutorialView setHidden:NO];
            });
        }
        [self updateViewWithValidRecommendation];
    }else{
        [self updateViewInCaseOfNoRecommendation];
    }
}

- (void)didFailToGenerateRandomRecommendationWithError:(NSError *)error{
    [self updateViewInCaseOfNoRecommendation];
    [DiceLogger logWithClass:[self class]
                             Message:@"Failed to fetch random Yelp recommendation with error"
                            andError:error];
}


#pragma mark - UI Drawing Methods

-(void)updateViewWhileFetchingRecommendation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearViewElements];
        [_loadingRecommendation startAnimating];
        _loadingRecommendationMessage.hidden = NO;
    });
}

-(void)updateViewInCaseOfNoRecommendation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearViewElements];
        _recommendationError.hidden = NO;
    });
}

-(void)updateViewWithValidRecommendation{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearViewElements];
        
        _recommendationBusinessName.text =
        _randomRecommendation.name;
        _recommendationBusinessName.hidden = NO;
        
        _recommendationBusinessCategory.text =
        _randomRecommendation.categories;
        _recommendationBusinessCategory.hidden = NO;
        
        _recommendationBusinessReviewCount.text =
        [NSString stringWithFormat:@"%ld reviews",
         (long)_randomRecommendation.reviewCount];
        _recommendationBusinessReviewCount.hidden = NO;
        
        _recommendationBusinessSnippet.text =
        [NSString stringWithFormat:@"\"%@\"",
         _randomRecommendation.snippetAboutBusiness];
        _recommendationBusinessSnippet.hidden = NO;
        
        _recommendationBusinessDistance.text =
        [NSString stringWithFormat:@"%.2f miles",
         _randomRecommendation.distanceInMiles];
        _recommendationBusinessDistance.hidden = NO;
        
        _recommendationBusinessStreetAddress.text =
        _randomRecommendation.streetAddress;
        _recommendationBusinessStreetAddress.hidden = NO;
        
        [_randomRecommendation
         downloadBusinessImageIfRequiredAndDisplayInImageView:_recommendationBusinessImage];
        [_randomRecommendation
         downloadRatingImageIfRequiredAndDisplayInImageView:_recommendationBusinessRatingImage];
    });
}

-(void)clearViewElements{
    _recommendationBusinessName.hidden = YES;
    _recommendationBusinessCategory.hidden = YES;
    _recommendationBusinessReviewCount.hidden = YES;
    _recommendationBusinessSnippet.hidden = YES;
    _recommendationBusinessDistance.hidden = YES;
    _recommendationBusinessStreetAddress.hidden = YES;
    _recommendationBusinessImage.hidden = YES;
    _recommendationBusinessRatingImage.hidden = YES;
    _recommendationError.hidden = YES;
    _loadingRecommendationMessage.hidden = YES;
    [_loadingRecommendation stopAnimating];
}


#pragma mark - ShakeDetectionDelegate

// Fetch a new recommendation after registering a shake motion
-(void)shakeDetected{
    
    [self updateViewWhileFetchingRecommendation];
    [_recommender fetchRandomRecommendation];
}


#pragma mark - ViewController Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
}


-(void)viewWillAppear:(BOOL)animated{
    self.mainView.delegate = self;
    [self.mainView becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated{
    [self.mainView resignFirstResponder];
}


#pragma mark - Tutorial View Functionality
/*Reading a boolean key from NSUserDefaults to check if this is the first
 launch of the app ever*/
-(BOOL)firstAppLaunch{
    if ([[NSUserDefaults standardUserDefaults]
         boolForKey:DICE_FIRST_LAUNCH_KEY]){ return NO; }
    else
    {
        [[NSUserDefaults standardUserDefaults]
         setBool:YES forKey:DICE_FIRST_LAUNCH_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
}

/* Dismissing the tutorial overlay */
- (IBAction)tutorialViewCancelled {
    _isFirstAppLaunch = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tutorialView removeFromSuperview];
    });
}

@end
