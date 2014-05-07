//
//  DiceYelpConstants.h
//  Dice
//
//  Created by Arpan Ghosh on 5/6/14.
//  Copyright (c) 2014 Tracktor Beam. All rights reserved.
//


// Keys in the JSON disctionary returned by the Yelp API
#define YELP_ID_KEY @"id"
#define YELP_NAME_KEY @"name"
#define YELP_IMAGE_URL_KEY @"image_url"
#define YELP_SMALL_IMAGE_EXTENSION @"ms.jpg"
#define YELP_LARGE_IMAGE_EXTENSION @"l.jpg"
#define YELP_MOBILE_PROFILE_URL_KEY @"mobile_url"
#define YELP_REVIEW_COUNT_KEY @"review_count"
#define YELP_DISTANCE_KEY @"distance"
#define YELP_RATING_IMAGE_URL_KEY @"rating_img_url_large"
#define YELP_SNIPPET_TEXT_KEY @"snippet_text"
#define YELP_LOCATION_OBJECT_KEY @"location"
#define YELP_ADDRESS_OBJECT_KEY @"address"
#define YELP_CATEGORIES_KEY @"categories"
#define YELP_DISPLAY_ADDRESS_KEY @"display_address"
#define DICE_YELP_API_RESPONSE_ROOT_FIELD @"businesses"


#define METERS_TO_MILES_CONVERSION_FACTOR 0.000621371

// Yelp API authentication stuff
#define DICE_YELP_CONSUMER_KEY @"Uern3Sirc7UqgQ9cl_d2Kg"
#define DICE_YELP_CONSUMER_SECRET @"gG_0G9lovVTG2Sd4ZTLmag55KJY"
#define DICE_YELP_API_TOKEN @"OWyYIafAtafVTi8a12RvXbXJfdnbhPZB"
#define DICE_YELP_API_TOKEN_SECRET @"zvlHSLDDJqUKNR5wG220SoVvp3A"

// Yelp API URL template with token formatters to insert parameters
#define DICE_YELP_API_REQUEST_URL_TEMPLATE @"http://api.yelp.com/v2/search?term=restaurants&ll=%f,%f&radius_filter=3219&offset=%ld&limit=20"

/* Path of placeholder images in case actual restaurant image and 
 ratings image cannot be fetched from the web */
#define DICE_RESTAURANT_IMAGE_PLACEHOLDER @"image_not_available.png"
#define DICE_RATING_IMAGE_PLACEHOLDER @"image_not_available_small.png"